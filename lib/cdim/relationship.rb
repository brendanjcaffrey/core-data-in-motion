module CDIM
  class Relationship
    attr_reader :type
    class << self ; attr_reader :relationships end

    def initialize(origin, type, dest, options = {})
      @origin_class = origin.to_s.downcase.underscore
      @type = type
      @destination_name = dest.to_s.downcase
      @options = options

      # register the relationship so we can link up inverses when both classes exist
      self.class.register_relationship(@origin_class, @destination_name.singularize, self)
    end

    def to_property
      @property ||= begin
        property = NSRelationshipDescription.new

        # TODO ordered, deleteRule, indexed, trasient
        property.name = @destination_name
        property.destinationEntity = (@destination_name.singularize.camelize.constantize).entity_description # :employees => Employee => CDIMEmployee
        property.optional = !@options[:required]
        property.minCount = @options[:required] ? 1 : 0
        property.maxCount = [:has_one, :belongs_to].index(@type) != nil ? 1 : NSIntegerMax
        property.deleteRule = NSNullifyDeleteRule

        property
      end
    end

    # storing these as constants makes compilation fail :(
    @@collection_map = {
      :has_many => 'CDIM::Association::HasMany',
      :has_one => 'CDIM::Association::HasOne',
      :belongs_to => 'CDIM::Association::BelongsTo'
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
      @relationships ||= {}.with_indifferent_access
      @relationships.each do |parent, children|
        children.each do |child, child_relationship|
          next unless @relationships[child][parent] # can't link up a one-sided relationship

          child_relationship_property = child_relationship.to_property
          parent_relationship_property = @relationships[child][parent].to_property
          parent_entity = child_relationship_property.destinationEntity

          child_relationship_property.inverseRelationship = parent_relationship_property
          parent_entity.properties += [parent_relationship_property]
        end
      end
    end
  end
end

