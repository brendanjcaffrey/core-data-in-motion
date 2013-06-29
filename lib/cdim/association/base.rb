module CDIM::Association
  class Base
    attr_reader :relationship, :child_class, :dirty 

    def initialize(relationship, model)
      @relationship = relationship
      @parent_class = model.class

      @parent_object = model
      # strip out CDIM to get the wrapper class
      @child_class = String.new(relationship.to_property.destinationEntity.name)[4..-1].constantize
      @dirty = false
    end
  end
end
