# frozen_string_literal: true

module ActionController::WithPolicy
  extend ActiveSupport::Concern

  prepended do
    if respond_to? :helper_method
      helper_method :can?
      helper_method :policy_scope
      helper_method :policy
    end
  end

  def can?(object, action = action_name)
    policy(object).public_send("#{action}?")
  end

  def policy_scope(relation)
    policy = policy(relation.klass)
    policy.scope(relation)
  end

  def policy_params(object, action = action_name)
    policy = policy(object)
    params_method = policy.respond_to?("params_for_#{action}") ? "params_for_#{action}" : 'params'
    params.require(policy.param_key).permit(*policy.public_send(params_method))
  end

  def policy(object)
    (@_policy ||= {})[object] ||= begin
      policy = if object
        klass = object.is_a?(Class) ? object : object.class
        "#{klass.name}Policy".to_const ||
          "#{klass.superclass.name}Policy".to_const ||
          "#{klass.base_class.name}Policy".to_const ||
          ApplicationPolicy
      else
        ApplicationPolicy
      end
      policy.new(Current.user, object)
    end
  end

  protected

  def set_current
    super
    set_current_user
    set_current_role
  end

  def set_current_user
    return Current.user = User::Null.new unless respond_to? :session
    user_id = session[:user_id]
    user   = User.with_discarded.joins(:session).where(id: user_id).take if user_id.to_i?
    user ||= User::Null.new
    Current.user = user
  end

  def set_current_role
    return Current.role = :null unless respond_to? :session
    role = params[:_role].presence || request.headers['X-Role'].presence || cookies[:_role].presence
    unless User.roles.has_key? role
      role = session[:role].presence || Current.user.role
    end
    role ||= :null
    session[:role] = cookies[:_role] = role.to_s
    Current.role = role.to_sym
  end
end
