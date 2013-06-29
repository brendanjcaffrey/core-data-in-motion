module CDIM
  describe Attribute do
    describe '.initialize' do
      it 'should convert the symbolized type to a constant from NSAttributeType' do
        CDIM::Attribute::TYPE_MAP.each do |sym, const|
          attr = Attribute.new('', sym)
          attr.type.should == const
        end
      end

      it 'should set the name property through the initializer' do
        attr = Attribute.new('id', :int16)
        attr.property_name.should == 'id'
      end

      it 'should set the require attributed if passed in the options but make it false otherwise' do
        attr = Attribute.new('id', :int16, :required => true)
        attr.required.should == true

        attr = Attribute.new('id', :int16, :required => false)
        attr.required.should == false

        attr = Attribute.new('id', :int16)
        attr.required.should == false
      end

      it 'should set the default attriute if passed in the options but make it nil otherwise' do
        attr = Attribute.new('id', :int16, :default => 6)
        attr.default.should == 6

        attr = Attribute.new('id', :int16)
        attr.default.should == nil
      end

      it 'should set the enum attribute if that is the type that\'s passed in' do
        attr = Attribute.new('id', :enum)
        attr.enum.should == true

        attr = Attribute.new('id', :int16)
        attr.enum.should == false
      end

      it 'should append to @name and set @enum_name to the original name passed in if the type is :enum' do
        attr = Attribute.new('id', :enum)
        attr.property_name.should == 'id' + Attribute::ENUM_CODE_APPEND
        attr.access_name.should == 'id'
      end
    end

    describe '.display_value' do
      it 'should return the argument if the attribute is not an enum' do
        attr = Attribute.new('test', :int16)
        attr.display_value(100).should == 100
      end

      it 'should return the enum value if the attribute is an enum' do
        attr = Attribute.new('test', :enum, :values => [:a, :b, :c])
        attr.display_value(0).should == :a
        attr.display_value(1).should == :b
        attr.display_value(2).should == :c
      end
    end

    describe '.stored_value' do
      it 'should return the argument if the attribute is not an enum' do
        attr = Attribute.new('test', :int16)
        attr.display_value(100).should == 100
      end

      it 'should return the enum index if the attribute is an enum' do
        attr = Attribute.new('test', :enum, :values => [:a, :b, :c])
        attr.stored_value(:a).should == 0
        attr.stored_value(:b).should == 1
        attr.stored_value(:c).should == 2
      end
    end
  end
end
