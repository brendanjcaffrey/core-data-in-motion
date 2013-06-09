module CDIM
  class RelationshipCollection
    attr_reader :relationship, :child_class, :dirty

    def initialize(relationship, model)
      @relationship = relationship
      @parent_class = model.class

      @parent_object = model
      # strip of CDIM to get the wrapper class
      @child_class = String.new(relationship.to_property.destinationEntity.name)[4..-1].constantize
      @dirty = false
    end
  end

  class HasManyCollection < RelationshipCollection
    attr_reader :collection
  end

  class HasOneCollection < RelationshipCollection
    attr_reader :object

    def get_object
      if @dirty
        @new_child
      else
        @child_object ||= begin
          child = @parent_object.managed_object.send(@relationship.to_property.name)
          child ? @child_class.new(child) : nil
        end

      end
    end

    def set_object(obj)
      @new_child = obj
      obj.save if obj and !@parent_object.orphaned

      @dirty = true
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
        name = @relationship.to_property.name.to_s + '='

        # move it over and save to generate the managed object if it's orphaned
        @child_object = @new_child
        @child_object.save or raise 'Unable to save child object' if @child_object and @child_object.orphaned

        mob = @child_object ?  @child_object.managed_object : nil
        @parent_object.managed_object.send(name, mob)
        Store.shared.save

        @dirty = false
      end

      true
    end
  end

  class BelongsToCollection < HasOneCollection
  end
end
