module CDIM
  class Attribute
    attr_reader :name, :type, :required, :default

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
      # TODO deal with NSTransformableAttributeType, NSObjectIDAttributeType?
    }

    def initialize(name, type, options = {})
      raise ('Invalid type ' + type.to_s) unless TYPE_MAP[type] != nil

      @name = name
      @type = TYPE_MAP[type]

      if options[:required]
        @required = !!options[:required] # convert to boolean
      else
        @required = false
      end

      if options[:default] != nil
        @default = options[:default]
      else
        @default = nil
      end
    end
  end
end
