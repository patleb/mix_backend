# frozen_string_literal: true

module MixPage
  has_config do
    attr_accessor :root_path
    attr_writer   :root_template
    attr_writer   :layout
    attr_writer   :available_layouts
    attr_writer   :available_templates
    attr_writer   :available_field_types
    attr_writer   :available_field_names
    attr_writer   :available_fieldables
    attr_writer   :member_actions
    attr_writer   :max_image_size
    attr_accessor :skip_sidebar
    attr_accessor :skip_content

    def root_template
      @root_template ||= 'home'
    end

    def layout
      @layout ||= 'pages'
    end

    def available_layouts
      @available_layouts ||= {
        'application' => 0,
        'pages' => 10,
      }
    end

    def available_templates
      @available_templates ||= {
        'home' => 0,
      }
    end

    def available_field_types
      @available_field_types ||= {
        'PageFields::Text' => 0,
        'PageFields::Html' => 10,
        'PageFields::Link' => 20,
      }
    end

    def available_field_names
      @available_field_names ||= {
        sidebar: 0,
        content: 10,
      }
    end

    def available_fieldables
      @available_fieldables ||= {
        'PageTemplate' => 0
      }
    end

    def member_actions
      @member_actions ||= %i(edit delete)
    end

    def max_image_size
      @max_image_size ||= 5.megabytes
    end
  end
end
