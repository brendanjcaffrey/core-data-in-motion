module CDIM
  module Entity
    extend MotionSupport::Concern

    module ClassMethods
      def entity_class_prefix
        'CDIM'
      end

      def entity_description
        @entity ||= begin
          entity = NSEntityDescription.new

          entity.name = self.entity_name
          entity.managedObjectClassName = self.entity_name
          entity.properties = self.attributes.values.collect(&:to_property) # wire relationships later

          entity
        end
      end

      def entity_name
        self.entity_class.to_s
      end

      def entity_class
        Object.const_get(entity_class_prefix + self.to_s)
      end

      def object_in_context
        entity = NSEntityDescription.entityForName(self.entity_name, inManagedObjectContext:Store.shared.context)
        self.entity_class.alloc.initWithEntity(entity, insertIntoManagedObjectContext:Store.shared.context)
      end

      def define_managed_subclass(wrapper_class)
        entity_name = entity_class_prefix + wrapper_class.to_s

        # define the subclass of NSManagedObject that CoreData needs
        # prepend it with CDIM because we can't use the same class name
        Object.const_set(entity_name,
          Class.new(NSManagedObject) do
            class << self ; attr_accessor :wrapper_class end
          end
        )

        entity_name.constantize.send('wrapper_class=', wrapper_class)
      end
    end

    protected

    def write_hash_to_managed_object(hash)
      hash.each { |key, value| @managed_object.setValue(value, forKey:key) }
    end
  end
end
