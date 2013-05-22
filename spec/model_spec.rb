module CDIM
  describe Model do
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

    describe 'update_attributes' do
      it 'should update the objects values with the specified attributes' do
        model = TestModel.create(:string_field => 'original')
        model.string_field.should == 'original'

        lambda { model.update_attributes(:string_field => 'updated') }.should.change { model.string_field }
        TestModel.all.first.string_field.should == 'updated'
      end
    end

    describe 'destroy' do
      it 'should delete the object permanently' do
        model = TestModel.create
        lambda { model.destroy }.should.change { TestModel.all.count }
      end

      it 'should not all allow resaving' do
        model = TestModel.create(:int_field => 4)
        model.destroy

        lambda { model.save }.should.not.change { TestModel.all.count }
      end
    end

    describe 'all' do
      it 'should return all models without caching and order by creation order' do
        TestModel.all.count.should == 0

        TestModel.create(:string_field => '1')
        all = TestModel.all
        all.count.should == 1
        all.first.is_a?(TestModel).should == true
        all.first.string_field.should == '1'

        TestModel.create(:string_field => '2')
        all = TestModel.all
        all.count.should == 2
        all.last.is_a?(TestModel).should == true
        all.last.string_field.should == '2'
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

    describe 'defaults' do
      it 'should use the default value if none is specified' do
        test = TestDefault.create
        test.string_field.should == TestDefault::DEFAULT_VALUE
        TestDefault.all.count.should == 1
      end

      it 'should not use the default value if a new value is specified' do
        test = TestDefault.create(:string_field => 'not-default')
        test.string_field.should == 'not-default'
        TestDefault.all.count.should == 1
      end
    end

    describe 'timestamps' do
      it 'should use the current time for created_at/updated_at when creating an object with timestamp_properties' do
        now = Time.now

        test = TestTimestamp.create
        (test.created_at - now < 1.0).should == true
        (test.updated_at - now < 1.0).should == true
      end

      it 'should update updated_at when touch is called' do
        test = TestTimestamp.create
        lambda { test.touch }.should.change { TestTimestamp.all.first.updated_at }
      end

      it 'should not update updated_at when update_attributes is called with no attributes' do
        test = TestTimestamp.create
        lambda { test.update_attributes({}) }.should.not.change { TestTimestamp.all.first.updated_at }
      end

      it 'should update updated_at when update_attributes is called with attributes' do
        test = TestTimestamp.create
        lambda { test.update_attributes(:string_field => 'test') }.should.change { TestTimestamp.all.first.updated_at }
      end

      it 'should not update updated_at when save is called with no changes' do
        test = TestTimestamp.create
        lambda { test.save }.should.not.change { TestTimestamp.all.first.updated_at }
      end

      it 'should update updated_at when save is called with changes' do
        test = TestTimestamp.create
        test.string_field = 'test'
        lambda { test.save }.should.change { TestTimestamp.all.first.updated_at }
      end

      it 'should allow the updated_at value to be overwritten' do
        test = TestTimestamp.create
        test.updated_at = test.updated_at
        lambda { test.save }.should.not.change { TestTimestamp.all.first.updated_at }
      end
    end

    describe 'required' do
      it 'should refuse to save without a required field and remove the object from the store' do
        lambda { TestRequired.create(:optional_string => 'oh no') }.should.raise(RuntimeError)

        # even though the object didn't save, CoreData would still return it unless it gets removed from the store
        TestRequired.all.count.should == 0
      end
    end

    describe 'enum' do
      it 'should work in create and update_attributes' do
        model = TestEnum.create(:test => :two)
        model.test.should == :two

        lambda { model.update_attributes(:test => :three) }.should.change { model.test }

        TestEnum.all.first.test.should == :three
      end

      it 'should allow a value as default' do
        model = TestEnum.create
        model.test.should == TestEnum::DEFAULT_VALUE
      end

      it 'should define a getter and setter' do
        model = TestEnum.create(:test => :one)

        model.respond_to?(:test).should == true
        model.respond_to?(:test=).should == true

        model.test.should == :one
        model.test = :two
        model.test.should == :two
      end
    end
  end
end
