module CDIM
  class HasManyCollection < RelationshipCollection
    def get_object
      @collection ||= begin
        children = nil

        mutable_set = @parent_object.managed_object.send(@relationship.to_property.name) if @parent_object.managed_object
        children = mutable_set.allObjects if mutable_set

        if children.is_a?(Array)
          build_proxy(children.map { |child| @child_class.new(child) })
        else
          build_proxy
        end
      end
    end

    def set_object(arr)
      raise ArgumentError, 'Trying to set a collection to non-array' unless arr.is_a?(Array)

      @dirty = true
      @collection = build_proxy
      push(arr)
    end

    def push(args)
      raise ArgumentError, 'Trying to add to a collection with a non-member of the child class' if !args.is_a?(Array) and !args.is_a?(@child_class)

      args = [args] if args.is_a? @child_class
      proxy = get_object

      args.each do |obj|
        obj.save unless @parent_object.new_record?
        proxy.array.push(obj) unless proxy.include?(obj)
      end

      @dirty = true
      save unless @parent_object.new_record?

      @collection
    end

    def build(args = {})
      obj = @child_class.new(args)
      get_object.array.push(obj)
      @dirty = true

      obj
    end

    def create(args = {})
      obj = @child_class.new(args)
      push(obj)

      obj
    end

    def clear
      get_object.array.clear
      save
    end

    def destroy(obj)
      return unless obj.is_a? @child_class

      proxy = get_object
      index = 0

      while (index < proxy.array.length) do
        if !proxy.array[index].new_record? and proxy.array[index].managed_object == obj.managed_object
          proxy.array[index].destroy
          proxy.array.delete_at(index) 
        else
          index = index.next
        end
      end

      proxy
    end

    def destroy_all
      get_object.array.each do |obj|
        obj.delete
      end

      true
    end

    def save
      name = @relationship.to_property.name.to_s + '='
      objs = []

      get_object.array.each do |obj|
        objs << obj.managed_object unless obj.new_record?
      end

      @parent_object.managed_object.send(name, NSSet.setWithArray(objs))
      CDIM::Store.shared.save
    end

    private
    def build_proxy(args = [])
      HasManyArrayProxy.new(self, args)
    end
  end
end
