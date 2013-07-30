module CDIM
  describe Querying do
    before do
      CDIM::Store.shared.delete_all!

      TestModel.create(:string_field => 'one', :int16_field => 2)
      TestModel.create(:string_field => 'two', :int16_field => 4)
      TestModel.create(:string_field => 'three', :int16_field => 1)

      @first_date = NSDate.dateWithTimeIntervalSinceNow(-1000000)
      @last_date = NSDate.dateWithTimeIntervalSinceNow(1000000)

      TestTimestamp.create(:created_at => @last_date)
      TestTimestamp.create
      TestTimestamp.create(:created_at => @first_date)
    end

    describe '.first' do
      it 'should return the first object by creation if no column is specified' do
        TestModel.first.string_field.should == 'one'
      end

      it 'should return the first ascending if a column is specified' do
        TestModel.first(:int16_field).int16_field.should == 1
      end

      it 'should use the created_at field to order if no column is specified and the model uses timestamps' do
        TestTimestamp.first.created_at.should == @first_date
      end

      it 'should throw an exception if trying to order by a non-existent column' do
        lambda { TestModel.first(:doesntexist) }.should.raise(ArgumentError)
      end
    end

    describe '.last' do
      it 'should return the first object by creation if no column is specified' do
        TestModel.last.string_field.should == 'three'
      end

      it 'should return the first ascending if a column is specified' do
        TestModel.last(:int16_field).int16_field.should == 4
      end

      it 'should use the created_at field to order if no column is specified and the model uses timestamps' do
        TestTimestamp.last.created_at.should == @last_date
      end

      it 'should throw an exception if trying to order by a non-existent column' do
        lambda { TestModel.last(:doesntexist) }.should.raise(ArgumentError)
      end
    end
  end
end
