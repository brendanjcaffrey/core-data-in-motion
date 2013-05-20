module CDIM
  describe ManagedObject do
    before do
      CDIM::Store.shared.delete_all!
    end

    describe 'create' do
      it 'should create an object with the specified attributes' do
        TestModel.create(:string_field => 'hello')

        model = CDIM::Store.shared.get_all('TestModel').first
        model.string_field.should == 'hello'

        CDIM::Store.shared.remove(model)
      end
    end

    describe 'update_attributes' do
      it 'should update the objects values with the specified attributes' do
        TestModel.create(:string_field => 'original')

        model = CDIM::Store.shared.get_all('TestModel').first
        model.string_field.should == 'original'

        model.update_attributes(:string_field => 'updated')
        model.string_field.should == 'updated' # test that it updates the object

        # reload and test again
        new_model = CDIM::Store.shared.get_all('TestModel').first
        new_model.string_field.should == 'updated'
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

        CDIM::Store.shared.remove(TestModel.all.first)
        all = TestModel.all
        all.count.should == 1
        all.first.string_field.should == '2'
      end
    end

    describe 'defaults' do
      it 'should use the default value if none is specified' do
        TestDefault.create

        test = CDIM::Store.shared.get_all('TestDefault').first
        test.string_field.should == TestDefault::DEFAULT_VALUE

        CDIM::Store.shared.remove(test)
      end

      it 'should not use the default value if a new value is specified' do
        TestDefault.create(:string_field => 'not-default')

        test = CDIM::Store.shared.get_all('TestDefault').first
        test.string_field.should == 'not-default'

        CDIM::Store.shared.remove(test)
      end
    end

    describe 'timestamps' do
      it 'should use the current time for created_at/updated_at when creating an object with timestamp_properties' do
        now = Time.now

        TestTimestamp.create
        test = CDIM::Store.shared.get_all('TestTimestamp').first
        (test.created_at - now < 5).should == true
        (test.updated_at - now < 5).should == true
      end

      it 'should update updated_at when calling update_attributes' do
        TestTimestamp.create
        test = CDIM::Store.shared.get_all('TestTimestamp').first
        (test.created_at - test.updated_at < 0.1).should == true
        updated = test.updated_at

        sleep 1 # TODO mock Time.now instead of this to speed up tests (is that possible?)
        test.update_attributes({})
        new = CDIM::Store.shared.get_all('TestTimestamp').first
        puts new.updated_at - updated
        (new.updated_at - updated > 1.0).should == true
      end
    end

    describe 'enum' do
      it 'should work in create and update_attributes' do
        TestEnum.create(:test => :two)

        model = CDIM::Store.shared.get_all('TestEnum').first
        model.test.should == :two

        model.update_attributes(:test => :three)
        model.test.should == :three

        new_model = CDIM::Store.shared.get_all('TestEnum').first
        new_model.test.should == :three
      end

      it 'should allow a value as default' do
        TestEnum.create

        model = CDIM::Store.shared.get_all('TestEnum').first
        model.test.should == TestEnum::DEFAULT_VALUE
      end

      it 'should define a getter and setter' do
        TestEnum.create(:test => :one)

        model = CDIM::Store.shared.get_all('TestEnum').first
        model.respond_to?(:test).should == true
        model.respond_to?(:test=).should == true

        model.test.should == :one
        model.test = :two
        model.test.should == :two
      end
    end
  end
end
