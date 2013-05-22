class TestModel < CDIM::Model
  property :int16_field, :int16
  property :double_field, :double
  property :float_field, :float
  property :string_field, :string
  property :bool_field, :boolean
  property :date_field, :date
  property :binary_field, :binary
end

class TestDefault < CDIM::Model
  DEFAULT_VALUE = 'default'
  property :string_field, :string, :default => 'default'
end

class TestTimestamp < CDIM::Model
  timestamp_properties
  property :string_field, :string
end

class TestRequired < CDIM::Model
  property :required_string, :string, :required => true
  property :optional_string, :string, :required => false
end

class TestEnum < CDIM::Model
  VALUES = [:one, :two, :three]
  DEFAULT_VALUE = VALUES.first
  property :test, :enum, :values => VALUES, :default => DEFAULT_VALUE
end

class TestHasMany < CDIM::Model
  has_many :test_children
end

class TestChild < CDIM::Model
  belongs_to :test_has_many
end

