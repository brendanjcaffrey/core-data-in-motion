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
        TestModel.first.string_field.should == TestModel.all.first.string_field
      end

      it 'should return a CDIM model, not an NSManagedObject subclass' do
        TestModel.first.should.be.an.instance_of? TestModel
      end

      it 'should take the number of records to return' do
        first_should = TestModel.first(2)
        first_all = TestModel.all.first(2)

        first_should[0].string_field.should == first_all[0].string_field
        first_should[1].string_field.should == first_all[1].string_field
      end
    end

    describe '.last' do
      it 'should return the first object by creation if no column is specified' do
        TestModel.last.string_field.should == TestModel.all.last.string_field
      end

      it 'should return a CDIM model, not an NSManagedObject subclass' do
        TestModel.last.should.be.an.instance_of? TestModel
      end

      it 'should take the number of records to return' do
        last_should = TestModel.last(2)
        last_all = TestModel.all.last(2)

        last_should[0].string_field.should == last_all[0].string_field
        last_should[1].string_field.should == last_all[1].string_field
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

    describe '.order' do
      it 'use ascending by default' do
        order = TestModel.order(:int16_field)
        order[0].int16_field.should == 1
        order[1].int16_field.should == 2
        order[2].int16_field.should == 4
      end

      it 'should take a string as well' do
        order = TestModel.order('int16_field')
        order[0].int16_field.should == 1
        order[1].int16_field.should == 2
        order[2].int16_field.should == 4
      end

      it 'should still sort ascending with ascending in the parameter' do
        order = TestModel.order('int16_field ASCENDING')
        order[0].int16_field.should == 1
        order[1].int16_field.should == 2
        order[2].int16_field.should == 4
      end

      it 'should sort descending with descending in the parameter' do
        order = TestModel.order('int16_field descending')
        order[0].int16_field.should == 4
        order[1].int16_field.should == 2
        order[2].int16_field.should == 1
      end

      it 'should chain with first and last' do
        TestModel.order('int16_field descending').first.int16_field.should == 4
        TestModel.order('int16_field descending').last.int16_field.should == 1
      end
    end

    describe '.none' do
      it 'should return an empty collection' do
        TestModel.all.none.count.should == 0
      end
    end
  end
end
