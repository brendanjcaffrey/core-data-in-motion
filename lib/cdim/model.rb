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
      @managed_object = context_object

      obj = self.new(@managed_object)
      obj.write_defaults
      obj.write_attributes(attributes)
      obj.save

      obj
    end

    # updates attributes and saves
    def update_attributes(attributes)
      write_attributes(attributes)
      touch
    end

    def touch
      write_attribute('updated_at', Time.now) if self.class.timestamps
      save
    end

    def save
      @managed_object = self.context_object if @orphaned
      @orphaned = false

      if @dirty
        write_attributes_to_managed_object(@changes)
        @dirty = false
        @changes = {}
        Store.shared.save
      end
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

    def write_attributes_to_managed_object(hash)
      hash.each do |key, value|
        meth = "#{key}=".to_sym
        @managed_object.send(meth, value) if @managed_object.respond_to?(meth)
      end
    end

    def self.context_object
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
