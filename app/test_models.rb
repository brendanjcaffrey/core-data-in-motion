class TestModel < CDIM::ManagedObject
  property :int16_field, :int16
  property :double_field, :double
  property :float_field, :float
  property :string_field, :string
  property :bool_field, :boolean
  property :date_field, :date
  property :binary_field, :binary
end

class TestDefault < CDIM::ManagedObject
  DEFAULT_VALUE = 'default'
  property :string_field, :string, :default => 'default'
end

class TestTimestamp < CDIM::ManagedObject
  timestamp_properties
end

class TestRequired < CDIM::ManagedObject
  property :required_string, :string, :required => true
  property :optional_string, :string, :required => false
end

class TestEnum < CDIM::ManagedObject
  VALUES = [:one, :two, :three]
  DEFAULT_VALUE = VALUES.first
  property :test, :enum, :values => VALUES, :default => DEFAULT_VALUE
end
