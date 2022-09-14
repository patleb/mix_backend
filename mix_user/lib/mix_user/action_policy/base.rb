module ActionPolicy
  class NotAuthorizedError < ::StandardError; end

  class Base
    include ActiveSupport::LazyLoadHooks::Autorun

    attr_reader :user, :record

    delegate :actions, to: :class

    def self.actions
      @_actions ||= begin
        index = public_instance_methods.index(:record)
        public_instance_methods.each_with_index.select_map{ |m, i| m if i < index && m.end_with?('?') }
      end
    end

    def initialize(user, record)
      @user = user
      @record = record
    end

    def role
      @role ||= user.role.to_sym
    end

    def roles
      @roles ||= user.class.roles.keys
    end

    def param_key
      record.class.model_name.param_key
    end

    def params
      []
    end

    def scope(objects)
      self.class::Scope.new(user, objects).resolve
    end

    def method_missing(name, *args, **options, &block)
      if name.end_with? '?'
        self.class.send(:define_method, name) do
          false
        end
        send(name)
      else
        super
      end
    end

    def respond_to_missing?(name, _include_private = false)
      name.end_with?('?') || super
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, collection)
        @user = user
        @scope = collection.klass
      end

      def resolve
        scope.null
      end
    end
  end
end
