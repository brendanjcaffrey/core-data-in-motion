module CDIM
  describe Persistence do
    before do
      CDIM::Store.shared.delete_all!
    end

    describe 'create' do
      it 'should create an object with the specified attributes' do
        model = TestModel.create(:string_field => 'hello', :int16_field => 1)
        model.string_field.should == 'hello'
        model.int16_field.should == 1

        # make sure it saved
        CDIM::Store.shared.get_all(TestModel.entity_class).count.should == 1
      end
    end

    describe 'destroy' do
      it 'should delete the object permanently' do
        model = TestModel.create
        lambda { model.destroy }.should.change { TestModel.all.count }
      end

      it 'should not allow resaving' do
        model = TestModel.create(:int16_field => 4)
        model.destroy

        lambda { model.save }.should.not.change { TestModel.all.count }
      end

      it 'should have delete as an alias' do
        model = TestModel.new
        model.method(:destroy).should == model.method(:delete)
      end
    end

    describe 'save' do
      # CoreData saves the changes in any modified NSManagedObject, so make sure that if you change something,
      # then save a different one, the fist class isn't affected
      it 'shouldn\'t modify an object until it is supposed to be saved' do
        one = TestModel.create(:int16_field => 1)
        one.int16_field = 8
        two = TestModel.create(:int16_field => 2)
        two.int16_field = 3

        lambda { two.save }.should.not.change { TestModel.all.first.int16_field }
      end

      it 'should be able to create an object with Model.new and the setters' do
        test = TestModel.new
        test.int16_field = 100
        test.string_field = 'magic string'
        test.save

        new_test = TestModel.all.first
        new_test.int16_field.should == 100
        new_test.string_field.should == 'magic string'
      end
    end

    describe 'build' do
      it 'shouldn\'t save the object' do
        lambda { TestModel.build(:string_field => 'testing') }.should.not.change { TestModel.all.count }
      end

      it 'should set the attributes on the object and persist them when you call save' do
        model = TestModel.build(:string_field => 'testing', :int16_field => 7)
        model.string_field.should == 'testing'
        model.int16_field.should == 7

        model.save
        new_model = TestModel.all.first
        new_model.string_field.should == 'testing'
        new_model.int16_field.should == 7
      end
    end

    describe 'new_record?' do
      it 'should be a new record when using build' do
        Device.build(:name => 'abc').should.be.a.new_record?
      end

      it 'should be a new record when using new' do
        Device.new.should.be.a.new_record?
      end

      it 'should not be a new record when using create' do
        Device.create.should.not.be.a.new_record?
      end

      it 'should not be a new record if save is called' do
        device = Device.build(:name => 'abc')
        lambda { device.save }.should.change { device.new_record? }
      end

      it 'should not be a new record if save is called' do
        device = Device.new(:name => 'abc')
        lambda { device.save }.should.change { device.new_record? }
      end
    end

    describe 'required' do
      it 'should refuse to save without a required field and remove the object from the store' do
        lambda { TestRequired.create(:optional_string => 'oh no') }.should.raise(RuntimeError)

        # even though the object didn't save, CoreData would still return it unless it gets removed from the store
        TestRequired.all.count.should == 0
      end
    end
  end
end
