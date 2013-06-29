# Many thanks to http://swlkr.com/2013/01/02/an-intro-to-core-data-with-ruby-motion/
module CDIM
  class Store
    attr_reader :context

    # singleton
    def self.shared
      @shared ||= Store.new
    end

    # TODO: sort and other NSFetchRequest options
    def get_all(entity)
      entity = entity.to_s.camelize

      request = NSFetchRequest.new
      request.entity = NSEntityDescription.entityForName(entity.to_s.camelize, inManagedObjectContext:@context)

      error_ptr = Pointer.new(:object)
      data = @context.executeFetchRequest(request, error:error_ptr)
      raise "Error fetching data: #{error_ptr[0].description}" if data == nil
      data
    end

    def add(entity)
      yield NSEntityDescription.insertNewObjectForEntityForName(entity.to_s.camelize, inManagedObjectContext:@context)
      save
    end

    def update(instance, attributes = {})
      attributes.each { |key, value| instance.setValue(value, forKey: key) }
      instance.updated_at = Time.now if instance.respond_to?(:updated_at)
      save
    end

    def remove(instance)
      @context.deleteObject(instance)
      save
    end

    def delete_all!
      CDIM::Model.subclasses.each do |subclass|
        CDIM::Store.shared.get_all(subclass.entity_class).each do |obj|
          CDIM::Store.shared.remove(obj)
        end
      end

      true
    end

    def save
      error_ptr = Pointer.new(:object)
      raise "Error when saving the model: #{error_ptr[0].description}" unless @context.save(error_ptr)
      true
    end

    private

    def initialize
      Relationship.wire_relationships

      model = NSManagedObjectModel.new
      model.entities = Model.subclasses.map(&:entity_description)

      store = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      store_url = NSURL.fileURLWithPath(File.join(NSHomeDirectory(), 'Documents', 'cdim.sqlite'))

      error_ptr = Pointer.new(:object)
      if !store.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:store_url, options:nil, error:error_ptr)
        if error_ptr[0].description.index('134100') # the Cocoa error code for you need to migrate
          NSFileManager.defaultManager.removeItemAtURL(store_url, error:nil)
          raise "Can't add persistent SQLite store: #{error_ptr[0].description}" unless
            store.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:store_url, options:nil, error:error_ptr)
        else
          raise "Can't add persistent SQLite store: #{error_ptr[0].description}"
        end
      end

      context = NSManagedObjectContext.new
      context.persistentStoreCoordinator = store
      @context = context
    end
  end
end
