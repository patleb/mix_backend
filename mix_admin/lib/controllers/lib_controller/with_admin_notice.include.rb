module LibController::WithAdminNotice
  def success_notice(name, action = action_name)
    I18n.t('admin.flash.successful', name: name, action: I18n.t("admin.actions.#{action}.done"))
  end

  def error_notice(objects, name, action = action_name)
    notice = I18n.t('admin.flash.error', name: name, action: I18n.t("admin.actions.#{action}.done"))
    Array.wrap(objects).each do |object|
      unless object.errors.empty?
        notice += ExtRails::ERROR_SEPARATOR + object.errors.full_messages.join(ExtRails::ERROR_SEPARATOR)
      end
    end
    simple_format! notice
  end
end
