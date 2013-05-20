module CDIM
  class ManagedObject < NSManagedObject

    # updates attributes and saves
    def update_attributes(attributes)
      Store.shared.update(self, attributes)
    end

    # creates an object with attributes and saves
    def self.create(attributes = {})
      attrs = attributes.with_indifferent_access

      Store.shared.add(self.entity_name) do |inst|
        attributes.each do |key, value|
          meth = "#{key}=".to_sym
          inst.send(meth, value) if inst.respond_to?(meth)
        end
      end

      # TODO return created
    end

    def self.all
      Store.shared.get_all(self.entity_name)
    end

    # class definition methods:
    def self.timestamp_properties
      @timestamps = true
    end

    def self.property(name, type, options = {})
      @attributes ||= []
      if type == :enum
        values = options.delete :values
        @attributes << Attribute.new(name, :enum, options)

        # define the getter and setter
        define_method(name.to_sym) { values[self.send(name + Attribute::ENUM_CODE_APPEND)] }
        define_method((name + '=').to_sym) { |sym| self.send(name + Attribute::ENUM_CODE_APPEND + '=', values.index(sym)) }
      else
        @attributes << Attribute.new(name, type, options)
      end
    end

    # TODO: has_many, has_one, belongs_to
    def self.has_many(name, options = {})
    end

    def self.has_one(name, options = {})
    end

    def self.belongs_to(name)
    end


    # this is how you set defaults (?)
    def awakeFromInsert
      super

      self.class.entity_class.attributes.each do |attr|
        if attr.enum
          send((attr.enum_name + '=').to_sym, attr.default)
        else
          setValue(attr.default, forKey:attr.name) if attr.default != nil
        end
      end

      if self.class.entity_class.timestamps
        setValue(Time.now, forKey:'created_at')
        setValue(Time.now, forKey:'updated_at')
      end
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
        (@attributes + self.timestamp_attributes).each do |attr|
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

    # track all subclasses (this only works for direct children TODO recurse?)
    def self.inherited(subclass)
      @subclasses ||= []
      @subclasses << subclass
    end

    def self.subclasses
      @subclasses ||= []
    end

    # define readers on the class so we can access the attributes from a dynamic subclass
    class << self
      attr_reader :attributes
      attr_reader :timestamps
    end

    protected

    # the following three methods are heavily inspired by MotionData (github.com/alloy/MotionData)
    # CoreData creates dynamic subclasses for the property setters/getters, so we have to deal with that
    # For a model called Foo, the dynamic class would be Foo_Foo_, so we have to return the original class
    def self.dynamic_subclass?
      self.to_s.include?('_')
    end

    def self.entity_name
      self.entity_class.to_s
    end

    def self.entity_class
      if self.dynamic_subclass?
        Object.const_get(self.to_s.split('_').first)
      else
        self
      end
    end

    def self.timestamp_attributes
      if self.entity_class.timestamps
        @timestamp_attributes ||= [Attribute.new('created_at', :date, :required => true),
                                   Attribute.new('updated_at', :date, :required => true)]
      else
        []
      end
    end
  end
end
