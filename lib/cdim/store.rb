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
      request.entity = NSEntityDescription.entityForName(entity, inManagedObjectContext:@context)

      error_ptr = Pointer.new(:object)
      data = @context.executeFetchRequest(request, error:error_ptr)
      raise "Error fetching data: #{error_ptr[0].description}" if data == nil

      data
    end

    def execute_fetch_request(request)
      error_ptr = Pointer.new(:object)
      ret = @context.executeFetchRequest(request, error:error_ptr)
      raise "Error when executing fetch request: #{error_ptr[0].description}" if ret == nil

      ret
    end

    def add(entity, values = nil)
      entity = NSEntityDescription.insertNewObjectForEntityForName(entity.to_s.camelize, inManagedObjectContext:@context)

      if values.is_a?(Hash)
        values.each { |key, val| entity.setValue(val, forKey:key) }
      else
        yield entity
      end

      save
    end

    def update(instance, attributes = {})
      attributes.each do |key, value|
        instance.send("#{key}=", value) if instance.respond_to?("#{key}=")
      end

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
        raise "Can't add persistent SQLite store: #{error_ptr[0].description}"
      end

      context = NSManagedObjectContext.new
      context.persistentStoreCoordinator = store
      @context = context
    end
  end
end

