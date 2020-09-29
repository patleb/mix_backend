module MixTemplate
  module WithLayoutValues
    extend ActiveSupport::Concern

    prepended do
      before_action :set_root_path, unless: :pjax?
      before_render :set_layout_values
      after_action  :versionize
    end

    private

    def set_root_path
      @root_path = respond_to?(:root_path) ? root_path : '/'
    end

    def set_layout_values
      @root_pjax = true
      @app_name = @page_title = @page_description = Rails.application.title
      @page_web_app_capable = MixTemplate.config.web_app_capable
      @page_version = MixTemplate.config.version
    end

    def versionize
      response.set_header('X-PAGE-VERSION', MixTemplate.config.version)
    end
  end
end
