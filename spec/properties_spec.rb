module CDIM
  describe Properties do
    before do
      CDIM::Store.shared.delete_all!
    end

    describe 'update_attributes' do
      it 'should update the objects values with the specified attributes' do
        model = TestModel.create(:string_field => 'original')
        model.string_field.should == 'original'

        lambda { model.update_attributes(:string_field => 'updated') }.should.change { model.string_field }
        TestModel.all.first.string_field.should == 'updated'
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
