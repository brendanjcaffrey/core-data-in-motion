module CDIM
  class Attribute
    attr_reader :type, :enum, :property_name, :access_name, :default, :required

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
      @property_name = name
      @access_name = name
      @type = TYPE_MAP[type]
      @required = !!options[:required]
      @default = options[:default]

      if @enum
        @property_name += ENUM_CODE_APPEND
        @values = options[:values]
      end
    end

    def display_value(val)
      return val unless @enum
      @values[val]
    end

    def stored_value(val)
      return val unless @enum
      @values.index val
    end

    def to_property
      @property ||= begin
        property = NSAttributeDescription.new

        property.name = @property_name
        property.attributeType = @type
        property.optional = !@required

        property
      end
    end
  end
end

