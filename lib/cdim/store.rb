# Many thanks to http://swlkr.com/2013/01/02/an-intro-to-core-data-with-ruby-motion/
module CDIM
  class Store
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
      attributes.each do |key, value|
        instance.send("#{key}=", value) if instance.respond_to?("#{key}=")
      end

      instance.updated_at = Time.now if instance.respond_to?(:updated_at)
      save
    end

    def remove(instance)
      assert(instance.klass < CDIM::ManagedObject)

      @context.deleteObject(instance)
    end

    private

    def initialize
      model = NSManagedObjectModel.new
      #model.entities = [ManagedObject.subclasses.map { |kl| kl.entity }]
      model.entities = [Machine.entity, Alarm.entity]

      store = NSPersistentStoreCoordinator.alloc.initWithManagedObjectModel(model)
      store_url = NSURL.fileURLWithPath(File.join(NSHomeDirectory(), 'Documents', 'cdim.sqlite'))
      error_ptr = Pointer.new(:object)
      raise "Can't add persistent SQLite store: #{error_ptr[0].description}" unless store.addPersistentStoreWithType(NSSQLiteStoreType, configuration:nil, URL:store_url, options:nil, error:error_ptr)

      context = NSManagedObjectContext.new
      context.persistentStoreCoordinator = store
      @context = context
    end

    def save
      error_ptr = Pointer.new(:object)
      raise "Error when saving the model: #{error_ptr[0].description}" unless @context.save(error_ptr)
    end
  end
end
