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

        model.update_attributes(:string_field => 'updated')
        model.string_field.should == 'updated' # test that it updates the object

        TestModel.all.first.string_field.should == 'updated'
      end
    end

    describe 'all' do
      it 'should return all models without caching' do
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

    describe 'setters and getters' do
      # CoreData saves the changes in any modified NSManagedObject, so make sure that if you change something,
      # then save a different one, the fist class isn't affected
      it 'shouldn\'t modify an object until it is supposed to be saved' do
        one = TestModel.create(:int16_field => 1)
        one.int16_field = 8
        two = TestModel.create(:int16_field => 2)
        two.int16_field = 3
        two.save

        all = TestModel.all
        all.first.int16_field.should == 1
        all.last.int16_field.should == 3
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
        (test.created_at - test.updated_at < 0.1).should == true
        updated = test.updated_at

        sleep 1 # TODO mock Time.now instead of this to speed up tests (is that possible?)
        test.touch

        new = TestTimestamp.all.first
        (new.updated_at - updated > 1.0).should == true
      end
    end

    describe 'enum' do
      it 'should work in create and update_attributes' do
        model = TestEnum.create(:test => :two)
        model.test.should == :two

        model.update_attributes(:test => :three)
        model.test.should == :three

        new_model = TestEnum.all.first
        new_model.test.should == :three
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
