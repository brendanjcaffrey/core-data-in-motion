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

    describe '.all' do
      it 'should return an array' do
        TestModel.all.should.be.an.instance_of? Array
      end

      it 'should return all objects' do
        TestModel.all.count.should == 3
      end

      it 'should return an array of CDIM::Models, not NSManagedObjects' do
        TestModel.all.each do |item|
          item.should.be.an.instance_of? TestModel
        end
      end

      it 'should order by created_at if there are no other sort descriptors and it has a created_at column' do
        models = TestTimestamp.all
        models[0].created_at.should == @first_date
        models[2].created_at.should == @last_date
      end
    end

    describe '.first' do
      it 'should return the first object by creation if no column is specified' do
        TestModel.first.string_field.should == 'one'
      end

      it 'should return a CDIM model, not an NSManagedObject subclass' do
        TestModel.first.should.be.an.instance_of? TestModel
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

      it 'should return a CDIM model, not an NSManagedObject subclass' do
        TestModel.last.should.be.an.instance_of? TestModel
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

    describe '.limit' do
      it 'should return only those number of items if there are more than that' do
        TestModel.limit(2).count.should == 2
      end

      it 'should return all items if there are more than that number of items' do
        TestModel.limit(5).count.should == 3
      end

      it 'should not return an array if the limit is 1' do
        TestModel.limit(1).should.be.an.instance_of? TestModel
      end
    end
  end
end
