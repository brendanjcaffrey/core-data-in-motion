module CDIM
  # the overarching goal of this class is to never touch the managed object or never create one until we know that it is being saved
  # calling save saves every CoreData object that's been modified, so avoiding modifying them unless they're being saved is the best bet here
  class Model
    attr_reader :managed_object, :orphaned, :changes

    class << self
      attr_reader :attributes, :timestamps, :defaults, :enums
    end

    # creates an object with attributes, saves and returns the new object
    def self.create(attributes = {})
      obj = self.new(attributes)
      obj.save

      obj
    end

    def self.build(attributes = {})
      self.new(attributes)
    end

    # updates attributes and saves
    def update_attributes(attributes)
      return if attributes == {}

      write_attributes(attributes)
      touch
    end

    def touch
      @dirty = true if self.class.timestamps
      save
    end

    def save
      @managed_object = self.class.object_in_context if @orphaned

      if @dirty
        write_updated_at unless @changes[:updated_at]
        write_hash_to_managed_object(@changes)
        begin
          Store.shared.save
        rescue RuntimeError => e
          # if we creaetd a new NSManagedObject, we have to remove it otherwise it'll show up in calls to .all
          # (even though it didn't save and wouldn't actually persist across app launches)
          if @orphaned
            Store.shared.remove(@managed_object)
            @managed_object = nil
          end

          raise e
        end

        @dirty = false
        @changes = {}
        @orphaned = false
      end
    end

    def destroy
      Store.shared.remove(@managed_object) unless @managed_object == nil

      # reset object state to disallow resaving
      @managed_object = nil
      @invalid = true
      @changes = nil
    end
    alias_method :delete, :destroy

    def new_record?
      @orphaned
    end

    def self.all
      Store.shared.get_all(self.entity_name).map { |mob| self.new(mob) }
    end

    def initialize(arg = {})
      @changes = {}

      if arg.is_a?(NSManagedObject)
        @orphaned = false
        @dirty = false
        @managed_object = arg
      else
        @orphaned = true
        @dirty = true

        write_defaults
        write_attributes(arg) if arg
      end
    end

    # class definition methods:
    def self.timestamp_properties
      @timestamps = true

      property('updated_at', :date, :required => true)
      property('created_at', :date, :required => true)
    end

    def self.property(name, type, options = {})
      @attributes ||= []
      @attributes << Attribute.new(name, type, options)

      @defaults ||= {}
      @defaults[name] = options[:default] if options[:default]

      @enums ||= {}
      @enums[name.to_sym] = options.delete :values if type == :enum

      define_method(name) { read_attribute(name) }
      define_method((name + '=').to_sym) { |val| write_attribute(name, val) }
    end

    # TODO: has_many, has_one, belongs_to
    def self.has_many(name, options = {})
    end

    def self.has_one(name, options = {})
    end

    def self.belongs_to(name)
    end

    # needed for building the NSManagedObjectModel
    def self.entity
      @attributes ||= []

      @entity ||= begin
        entity = NSEntityDescription.new
        entity.name = self.entity_name
        entity.managedObjectClassName = self.entity_name
        properties = []

        # timestamp_attributes returns [] if they aren't wanted
        @attributes.each do |attr|
          property = NSAttributeDescription.new

          property.name = attr.name
          property.attributeType = attr.type
          property.optional = !attr.required

          properties << property
        end

        entity.properties = properties
        entity
      end
    end

    def self.entity_name
      self.entity_class.to_s
    end

    def self.entity_class
      Object.const_get('CDIM' + self.to_s)
    end

    def read_attribute(attr)
      return nil if @invalid

      if self.class.enums[attr.to_sym]
        name = (attr.to_s + Attribute::ENUM_CODE_APPEND).to_sym
      else
        name = attr.to_sym
      end

      ret = @changes[name] || @managed_object.send(name)

      if self.class.enums[attr]
        self.class.enums[attr][ret]
      else
        ret
      end
    end

    def write_attribute(attr, value)
      return nil if @invalid

      if self.class.enums[attr.to_sym]
        @changes[(attr.to_s + Attribute::ENUM_CODE_APPEND).to_sym] = self.class.enums[attr.to_sym].index(value)
      else
        @changes[attr.to_sym] = value
      end

      @dirty = true
    end

    def write_attributes(hash)
      hash.each { |key, value| write_attribute(key, value) } if hash.is_a?(Hash)
    end

    def write_defaults
      write_attribute(:created_at, Time.now) if self.class.timestamps
      write_attribute(:updated_at, Time.now) if self.class.timestamps
      write_attributes(self.class.defaults)
    end

    private

    def write_hash_to_managed_object(hash)
      hash.each do |key, value|
        meth = "#{key}=".to_sym
        @managed_object.send(meth, value) if @managed_object.respond_to?(meth)
      end
    end

    def write_updated_at
      write_attribute('updated_at', Time.now) if self.class.timestamps
    end

    def self.object_in_context
      entity = NSEntityDescription.entityForName(self.entity_name, inManagedObjectContext:Store.shared.context)
      self.entity_class.alloc.initWithEntity(entity, insertIntoManagedObjectContext:Store.shared.context)
    end

    # track all subclasses (this only works for direct children TODO recurse?)
    def self.inherited(subclass)
      @subclasses ||= []
      @subclasses << subclass
      # define the subclass of NSManagedObject that CoreData needs
      # prepend it with CDIM because we can't use the same class name
      Object.const_set 'CDIM' + subclass.to_s, Class.new(NSManagedObject)
    end

    def self.subclasses
      @subclasses ||= []
    end
  end
end
