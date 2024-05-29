module CoffeeHelper
  def js_i18n(*scopes)
    ((@@js_i18n ||= {})[Current.locale] ||= {})[scopes] ||= begin
      div_('.js_i18n', data: {
        translations: scopes.each_with_object(I18n.t('js', default: {})) do |scope, all|
          all.merge! I18n.t('js', scope: scope, default: {})
        end
      })
    end
  end

  def js_routes
    div_('.js_routes', data: { paths: ExtCoffee.routes })
  end
end
