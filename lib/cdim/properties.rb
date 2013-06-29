module CDIM
  module Properties
    extend MotionSupport::Concern

    module ClassMethods
      attr_reader :attributes, :relationships, :timestamps, :defaults
      def timestamp_properties
        @timestamps = true

        property('updated_at', :date, :required => true)
        property('created_at', :date, :required => true)
      end

      def property(name, type, options = {})
        @attributes ||= {}.with_indifferent_access
        @attributes[name] = CDIM::Attribute.new(name, type, options)

        @defaults ||= {}.with_indifferent_access
        @defaults[name] = options[:default] if options[:default]

        property_methods(name)
      end

      def has_many(name, options = {})
        relationship(:has_many, name, options)
      end

      def has_one(name, options = {})
        relationship(:has_one, name, options)
      end

      def belongs_to(name, options = {})
        relationship(:belongs_to, name, options)
      end

      private

      def relationship(type, dest, options)
        @relationships ||= []
        @relationships << CDIM::Relationship.new(self, type, dest, options)

        if type == :has_many
          many_to_one_relationship_methods(dest)
        else
          one_to_one_relationship_methods(dest)
        end
      end

      def property_methods(name)
        define_method(name) { read_attribute(name) }
        define_method(name + '=') { |val| write_attribute(name, val) }
      end

      def one_to_one_relationship_methods(name)
        property_methods(name)

        define_method('build_' + name.to_s) { |args| collections[name].build_object(args) }
        define_method('create_' + name.to_s) { |args| collections[name].create_object(args) }
      end

      def many_to_one_relationship_methods(name)
        property_methods(name)
      end
    end

    def initialize(arg = {})
      @changes = {}.with_indifferent_access
      @collections = {}.with_indifferent_access

      # initialize all the relationship collections
      (self.class.relationships || []).each do |relation|
        @collections[relation.to_property.name] = relation.collection_manager_class.new(relation, self)
      end

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

    def read_attribute(attr_name)
      return nil if @invalid
      return @collections[attr_name].get_object if @collections[attr_name]

      @changes ||= {}.with_indifferent_access
      attr = self.class.attributes[attr_name]
      attr.display_value(@changes[attr.property_name] || @managed_object.valueForKey(attr.property_name))
    end

    def write_attribute(attr_name, value)
      return nil if @invalid

      @changes ||= {}.with_indifferent_access
      @dirty = true
      attr = self.class.attributes[attr_name]

      if attr
        @changes[attr.property_name] = attr.stored_value(value)
      elsif @collections[attr_name]
        @collections[attr_name].set_object(value)
      else
        raise ArgumentError 'Trying to write non-existent attribute: ' + attr_name.to_s
      end
    end

    def update_attributes(attributes)
      return if attributes == {}

      write_attributes(attributes)
      touch
    end

    def write_attributes(hash)
      hash.each { |key, value| write_attribute(key, value) } if hash.is_a?(Hash)
    end

    def write_defaults
      write_attribute(:created_at, Time.now) if self.class.timestamps
      write_attribute(:updated_at, Time.now) if self.class.timestamps
      write_attributes(self.class.defaults)
    end

    protected

    #attr_accessor :changes, :dirty

    def write_updated_at
      write_attribute('updated_at', Time.now) if self.class.timestamps
    end
  end
end
