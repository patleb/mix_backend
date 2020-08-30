module ActionService
  autoload :Base, 'ext_rails/action_service/base'
end

module ExtRails
  class Engine < ::Rails::Engine
    require 'active_type'
    require 'date_validator'
    require 'discard'
    require 'email_prefixer'
    require 'http_accept_language'
    require 'jsonb_accessor'
    require 'mail_interceptor' unless Rails.env.production?
    require 'monogamy'
    require 'pg'
    require 'rails-i18n'
    if Rails.env.development?
      require 'i18n/debug'
      require 'null_logger'
    end

    require 'sunzistrano/context'
    require 'ext_rails/action_mailer/smtp_settings'
    require 'ext_rails/active_support/core_ext'
    require 'ext_rails/active_support/lazy_load_hooks/autorun'
    require 'ext_rails/active_support/current_attributes'
    require 'ext_rails/active_support/string_inquirer'
    require 'ext_rails/active_support/dependencies/with_nilable_cache'
    require 'ext_rails/configuration'
    require 'ext_rails/money_rails'
    require 'ext_rails/rack/utils'
    require 'ext_rails/rails/engine'
    require 'ext_rails/rake/dsl'
    require 'ext_rails/sh'

    config.before_configuration do |app|
      require 'ext_rails/rails/application'
      require 'ext_rails/rails/initializable/collection'
      require 'ext_rails/pycall' if Setting[:postgis_enabled]

      if defined? MixGlobal
        app.config.active_record.cache_versioning = false # TODO doesn't work, must be added to Rails.root/config/application.rb
        app.config.cache_store = :global_store
      end
      app.config.active_record.schema_format = :sql
      app.config.action_mailer.delivery_method = :smtp
      app.config.action_mailer.smtp_settings = ActionMailer::SmtpSettings.new(Setting)
      app.config.action_view.embed_authenticity_token_in_remote_forms = true
      # app.config.active_record.time_zone_aware_attributes = false
      app.config.i18n.default_locale = :fr
      app.config.i18n.available_locales = [:fr, :en]
      app.config.i18n.fallbacks = [:en]
      # app.config.i18n.fallbacks = true

      if Rails.env.dev_or_test?
        $stdout.sync = true # for Foreman
        url_options = Rails.env.dev_or_test_url_options
        host, port = url_options.values_at(:host, :port)
        app.config.action_controller.asset_host = "#{host}#{":#{port}" if port}"
        app.config.action_mailer.asset_host = app.config.action_controller.asset_host
        app.config.action_mailer.default_url_options = url_options
        app.config.logger = ActiveSupport::Logger.new(app.config.paths['log'].first, 5)
        app.config.logger.formatter = app.config.log_formatter
      else
        app.config.action_mailer.default_url_options = -> { { host: Setting[:server_host] } }
      end
    end

    config.before_initialize do |app|
      require 'ext_rails/rails/initializable/initializer'

      if Rails.env.dev_or_test?
        Rails::Initializable::Initializer.exclude_initializers.merge!(
          'EmailPrefixer::Railtie' => 'email_prefixer.configure_defaults'
        )
      end
      # TODO Rails 6.0
      # ActiveStorage.routes_prefix '/storage'

      require 'ext_rails/action_dispatch/middleware/iframe'
      app.config.middleware.use ActionDispatch::IFrame
      app.config.middleware.insert_after ActionDispatch::Static, Rack::Deflater if Rails.env.dev_ngrok?

      %w(libraries tasks).each do |directory|
        ActiveSupport::Dependencies.autoload_paths.delete("#{app.root}/app/#{directory}")
      end

      unless Setting[:timescaledb_enabled]
        Rails.autoloaders.main.ignore("#{root}/app/models/concerns/timescaledb")
        Rails.autoloaders.main.ignore("#{root}/app/models/timescaledb")
      end

      unless Setting[:postgis_enabled]
        Rails.autoloaders.main.ignore("#{root}/app/models/postgis")
      end
    end

    initializer 'ext_rails.append_migrations' do |app|
      append_migrations(app)
      append_migrations(app, scope: 'pgrest') if Setting[:pgrest_enabled]
      append_migrations(app, scope: 'postgis') if Setting[:postgis_enabled]
      append_migrations(app, scope: 'timescaledb') if Setting[:timescaledb_enabled]
    end

    initializer 'ext_rails.append_routes' do |app|
      app.routes.append do
        match '/' => 'application#healthcheck', via: [:get, :head], as: :base

        match '*not_found', via: :all, to: 'application#render_404', format: false
      end
    end

    initializer 'ext_rails.default_url_options', before: 'action_mailer.set_configs' do |app|
      default_url_options = app.config.action_mailer.default_url_options
      if default_url_options.respond_to? :call
        app.config.action_mailer.default_url_options = default_url_options.call
      end
      app.routes.default_url_options = app.config.action_mailer.default_url_options
    end

    initializer 'ext_rails.i18n' do
      if defined? I18n::Debug
        unless ExtRails.config.i18n_debug
          I18n::Debug.logger = NullLogger.new
        end
      end

      MoneyRails.configure do |config|
        config.default_currency = :cad
        Money.locale_backend = :i18n
      end
    end

    initializer 'ext_rails.rack_lineprof' do |app|
      if (file = Rails.root.join('tmp/profile.txt')).exist? && (matcher = file.readlines.first&.strip).present?
        require 'ext_rails/rack_lineprof'
        app.middleware.use Rack::Lineprof, profile: matcher
      end
    end

    ActiveSupport.on_load(:action_controller, run_once: true) do
      require 'ext_rails/action_dispatch/routing/url_for/with_only_path'
      require 'ext_rails/action_controller/parameters'
    end

    ActiveSupport.on_load(:action_controller_api) do
      require 'ext_rails/action_controller/api'
    end

    ActiveSupport.on_load(:action_controller_base) do
      require 'ext_rails/action_controller/base'
    end

    ActiveSupport.on_load(:active_job) do
      require 'ext_rails/active_job/base'
    end

    ActiveSupport.on_load(:active_record) do
      require 'activerecord-postgis-adapter' if Setting[:postgis_enabled]
      require 'arel_extensions'
      require 'rails_select_on_includes'
      require 'store_base_sti_class'
      require 'ext_rails/active_type'
      require 'ext_rails/active_record/connection_adapters/postgis_adapter' if Setting[:postgis_enabled]
      require 'ext_rails/active_record/connection_adapters/postgresql_adapter'
      require 'ext_rails/active_record/base'
      require 'ext_rails/active_record/migration'
      require 'ext_rails/active_record/relation'
      require 'ext_rails/active_record/tasks/database_tasks/with_single_env'

      MixRescue.config.available_types.merge! 'RailsRescue' => 30
    end

    ActiveSupport.on_load(:action_mailer) do
      require 'ext_rails/action_mailer/base'
      require 'ext_rails/action_mailer/log_subscriber/with_quiet_info'
    end

    config.to_prepare do
      require 'ext_rails/active_support/lazy_load_hooks/autoload'
      ActiveSupport.autoload_hooks
    end
  end
end
