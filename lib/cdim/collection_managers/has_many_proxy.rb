module CDIM
  class HasManyArrayProxy
    extend Forwardable
    attr_accessor :owner, :array

    # these are the only functions that make immediate changes
    # TODO forward find/exists once DSL exists
    [:build, :create, :push, :clear, :destroy, :destroy_all].each { |func| def_delegator :@owner, func }
    alias_method :<<, :push
    alias_method :concat, :push
    alias_method :delete, :destroy
    alias_method :delete_all, :destroy_all

    # any write/update/destroy method here will not save automatically
    [:collect, :collect!, :count, :delete_at, :delete_if, :drop, :drop_while, :each, :each_index, :empty?, :fetch,
     :first, :index, :insert, :keep_if, :last, :length, :map, :map!, :pop, :reject, :reject!, :reverse, :reverse!,
     :reverse_each, :rindex, :rotate, :rotate!, :sample, :select, :select!, :shift, :shuffle, :shuffle!, :size,
     :slice, :slice!, :sort, :sort!, :sort_by!, :take, :take_while, :to_a, :to_ary, :to_s, :unshift, :values_at
    ].each { |func| def_delegator :@array, func }

    def initialize(owner, arr)
      @owner = owner
      @array = arr
    end

    def include?(other)
      if other.is_a? Model
        @array.each { |obj| return true if obj.managed_object == other.managed_object }
      end

      false
    end

    def inspect
      @array.inspect
    end
    alias_method :to_s, :inspect
  end
end

