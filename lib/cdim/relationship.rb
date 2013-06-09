module CDIM
  class Relationship
    # TODO ordered, deleteRule, indexed, trasient
    attr_reader :origin, :name, :type

    class << self
      attr_reader :relationships
    end

    def initialize(origin, type, dest, options = {})
      @origin = origin.to_s.downcase.underscore
      @type = type
      @dest = dest
      @options = options

      # register the relationship so we can link up inverses when both classes exist
      self.class.register_relationship(origin.to_s.downcase, dest.to_s.singularize, self)
    end

    def to_property
      @property ||= begin
        property = NSRelationshipDescription.new

        property.name = @dest.downcase
        property.destinationEntity = (@dest.to_s.singularize.camelize.constantize).entity_description # :employees => Employee => CDIMEmployee
        property.optional = !@options[:required]
        property.minCount = @options[:required] ? 1 : 0
        property.maxCount = [:has_one, :belongs_to].index(@type) != nil ? 1 : NSIntegerMax
        property.deleteRule = NSNullifyDeleteRule

        property
      end
    end

    # storing these as constants makes compilation fail :(
    @@collection_map = {
      :has_many => 'CDIM::HasManyCollection',
      :has_one => 'CDIM::HasOneCollection',
      :belongs_to => 'CDIM::BelongsToCollection'
    }
    def collection_manager_class
      @@collection_map[self.type].constantize
    end

    # linking up inverses is a chicken and egg problem -- so we keep track of all relationships behind the scene to later link them up
    def self.register_relationship(parent, child, rel)
      @relationships ||= {}.with_indifferent_access
      @relationships[parent] ||= {}.with_indifferent_access
      @relationships[parent][child] = rel
    end

    def self.wire_relationships
      @relationships.each do |parent, children|
        children.each do |child, child_relationship|
          next unless @relationships[child][parent]

          # trying to create the entity description when it first registers fails because the other class hasn't been defined yet
          child_relationship.to_property.inverseRelationship = @relationships[child][parent].to_property

          # this adds the relationship of the child entity to the entity description of the child entity and prevents the inclusion of non-mutual relationships
          child_relationship.to_property.destinationEntity.properties = child_relationship.to_property.destinationEntity.properties + [@relationships[child][parent].to_property]
        end
      end
    end
  end
end
