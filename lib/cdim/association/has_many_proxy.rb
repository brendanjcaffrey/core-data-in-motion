module CDIM::Association
  class HasManyArrayProxy < BasicObject
    attr_accessor :owner, :array

    def initialize(owner, arr)
      @owner = owner
      @array = arr
    end

    def include?(other)
      if other.is_a? ::CDIM::Model
        @array.each { |obj| return true if obj.managed_object == other.managed_object }
      end

      false
    end

    def method_missing(name, *arguments, &block)
      name = name.to_sym

      if DELEGATOR_METHODS[name] != nil
        @owner.send(DELEGATOR_METHODS[name], *arguments)
      elsif @array.respond_to? name
        @array.send(name, *arguments, &block)
      else
        super
      end
    end

    def respond_to_missing(name)
      DELEGATOR_METHODS[name] != nil || @array.respond_to?(name) || super
    end

    def try_to_delete(model)
      if model.new_record?
        @array.reject! { |obj| obj == model }
      elsif include?(model)
        @array.reject! { |obj| obj.managed_object == model.managed_object }
        model.delete
      end
    end

    private

    DELEGATOR_METHODS = {
      build: :build,
      create: :create,
      push: :push,
      :<< => :push,
      concat: :push,
      clear: :clear,
      destroy: :destroy,
      delete: :destroy,
      destroy_all: :destroy_all,
      delete_all: :destroy_all
    }
  end
end

