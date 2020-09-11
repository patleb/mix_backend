require 'ext_ruby'
require 'mix_page/configuration'
require 'mix_admin'

module MixPage
  URL_SEGMENT = 'page'.freeze
  MULTI_VIEW = '_multi'.freeze

  def self.js_routes
    @js_routes ||= {
      show: "/__SLUG__/#{URL_SEGMENT}/__UUID__",
      field_create: "/#{URL_SEGMENT}/__UUID__/field",
      field_update: "/#{URL_SEGMENT}/__UUID__/field/__ID__",
    }
  end

  class Engine < ::Rails::Engine
    initializer 'mix_page.append_migrations' do |app|
      append_migrations(app)
    end

    initializer 'mix_page.append_routes', before: 'ext_rails.append_routes' do |app|
      app.routes.append do
        get "/:slug/#{URL_SEGMENT}/:uuid" => 'pages#show', as: :page
        post "/#{URL_SEGMENT}/:uuid/field" => 'pages#field_create', as: :page_field
        patch "/#{URL_SEGMENT}/:uuid/field/:id" => 'pages#field_update', as: :edit_page_field
      end
    end
  end
end
