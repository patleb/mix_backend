require 'mix_page/configuration'
require 'mix_page/routes'
require 'mix_file'
require 'mix_admin'

module MixPage
  class Engine < ::Rails::Engine
    initializer 'mix_page.migrations' do |app|
      append_migrations(app)
    end

    initializer 'mix_page.routes', before: 'ext_rails.routes' do |app|
      app.routes.append do
        MixPage::Routes.draw(self)
      end
    end

    initializer 'mix_page.admin' do
      MixAdmin.configure do |config|
        config.included_models += %w(
          PageTemplate
          PageField
          PageFields::%
        )
      end
    end

    ActiveSupport.on_load(:active_record) do
      MixServer::Log.config.ided_paths[%r{/(#{MixPage::Routes::FRAGMENT})/([\w-]+)}] = '/\1/*'

      MixFile.configure do |config|
        config.available_records['PageFields::Html'] = 10
        config.available_associations['images'] = 100
      end
    end
  end
end
