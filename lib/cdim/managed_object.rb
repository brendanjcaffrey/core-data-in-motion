module CDIM
  class ManagedObject < NSManagedObject
    def update!(attributes)
      Store.shared.update(self, attributes)
    end

    def self.create!(attributes)
      attrs = attributes.with_indifferent_access

      Store.shared.add(self.entity_name) do |inst|
        # grab all the setters for this class so we can check if someone is passing in a
        # non-attribute setter
        meths = self.entity_class.instance_methods.delete_if { |x| !x.to_s.include?('=') }
        attrs = self.entity_class.attributes.map { |a| a.name }

        attributes.each do |key, value|
          inst.send(key + '=', value) if attrs.index(key) != nil or meths.include?("#{key}=:".to_sym)
        end
      end
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
      @attributes << Attribute.new(name, type, options)
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
        setValue(attr.default, forKey:attr.name) if attr.default != nil
      end

      if self.class.entity_class.timestamps
        setValue(Time.now, forKey:'created_at')
        setValue(Time.now, forKey:'updated_at')
      end
    end

    # needed for building the NSManagedObjectModel
    def self.entity
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
      subclasses << subclass
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

    def self.filter_out_non_attributes(hash)
      ret = {}
      hash = hash.with_indifferent_access

      self.entity_class.attributes.each do |attr|

        ret[attr.name] = hash[attr.name] if hash[attr.name] != nil
      end

      ret
    end
  end
end
