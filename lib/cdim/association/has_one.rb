module CDIM::Association
  class HasOne < Base
    def get_object
      if @dirty
        @new_child
      else
        @child_object ||= begin
          child = @parent_object.managed_object.valueForKey(@relationship.to_property.name)
          child ? @child_class.new(child) : nil
        end

      end
    end

    def set_object(obj)
      @new_child = obj
      obj.save if obj and !@parent_object.new_record?

      @dirty = true
      save unless @parent_object.new_record?
    end

    def clear_object!
      @new_child = nil
      @dirty = true

      save
    end

    def build_object(args)
      clear_object!
      @new_child = @child_class.new(args)
      @dirty = true

      @new_child
    end

    def create_object(args)
      # instead of calling build object, prevent the double save by just creating the object here
      @new_child = @child_class.new(args)
      @dirty = true
      save

      @child_object # save will move the value of @new_child into here and nil out @new_child
    end

    def save
      if @dirty
        # move it over and save to generate the managed object if it's orphaned
        @child_object = @new_child
        @child_object.save or raise 'Unable to save child object' if @child_object and @child_object.orphaned

        mob = @child_object ?  @child_object.managed_object : nil
        @parent_object.managed_object.setValue(mob, forKey: @relationship.to_property.name.to_s)
        CDIM::Store.shared.save

        @dirty = false
      end

      true
    end
  end
end

