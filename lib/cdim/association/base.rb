module CDIM::Association
  class Base
    attr_reader :relationship, :child_class, :dirty 

    def initialize(relationship, model)
      @relationship = relationship
      @parent_class = model.class
      @parent_object = model
      @dirty = false

      child_entity_class_name = relationship.to_property.destinationEntity.managedObjectClassName
      @child_class = Object.const_get(child_entity_class_name).wrapper_class
    end
  end
end

