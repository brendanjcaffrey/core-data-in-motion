module CDIM
  class Attribute
    attr_reader :name, :type, :required, :default, :enum, :enum_name

    ENUM_CODE_APPEND = '_enum_code'

    # http://stackoverflow.com/questions/10546632/list-of-core-data-attribute-types
    TYPE_MAP = {
      :int16 => NSInteger16AttributeType,
      :integer16 => NSInteger16AttributeType,
      :int32 => NSInteger32AttributeType,
      :integer32 => NSInteger32AttributeType,
      :int64 => NSInteger64AttributeType,
      :integer64 => NSInteger64AttributeType,
      :double => NSDoubleAttributeType,
      :float => NSFloatAttributeType,
      :string => NSStringAttributeType,
      :bool => NSBooleanAttributeType,
      :boolean => NSBooleanAttributeType,
      :date => NSDateAttributeType,
      :binary => NSBinaryDataAttributeType,
      :enum => NSInteger16AttributeType # custom attribute
      # TODO deal with NSTransformableAttributeType, NSObjectIDAttributeType?
    }

    def initialize(name, type, options = {})
      raise 'Invalid type ' + type.to_s unless TYPE_MAP[type] != nil

      @enum = type == :enum
      @name = name

      if @enum
        @name += ENUM_CODE_APPEND
        @enum_name = name
      else
        @enum_name = nil
      end

      @type = TYPE_MAP[type]
      @required = !!options[:required]
      @default = options[:default]
    end

    def to_property
      @property ||= begin
        property = NSAttributeDescription.new

        property.name = @name
        property.attributeType = @type
        property.optional = !@required

        property
      end
    end
  end
end
