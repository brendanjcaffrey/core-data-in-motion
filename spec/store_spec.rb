module CDIM
  describe Store do
    before do
      @share = Store.shared
      @model = TestModel.entity_class
      @share.delete_all!
    end

    describe '.get_all' do
      it 'should return all models without caching' do
        @share.get_all(@model).count.should == 0

        @share.add(@model) { |obj| obj.string_field = '1' }
        all = @share.get_all(@model)
        all.count.should == 1
        all.first.string_field.should == '1'

        @share.add(@model) { |obj| obj.string_field = '2' }
        all = @share.get_all(@model)
        all.count.should == 2
        all.last.string_field.should == '2'
      end
    end

    describe '.add' do
      it 'should take a model name and take a block that sets attributes' do
        @share.add(@model) { |obj| obj.int16_field = 1 }
        obj = @share.get_all(@model).first
        obj.int16_field.should == 1
      end
    end

    describe '.update' do
      it 'should take an instance and attributes to update' do
        @share.add(@model) { |obj| obj.int16_field = 3}
        obj = @share.get_all(@model).first
        obj.int16_field.should == 3
        obj.string_field.should == nil

        @share.update(obj, :int16_field => 4, :string_field => 'a')
        obj.int16_field.should == 4
        obj.string_field.should == 'a'
      end
    end

    describe '.remove' do
      it 'should remove the specified instance' do
        @share.add(@model) { |obj| }
        @share.get_all(@model).count.should == 1

        @share.remove(@share.get_all(@model).first)
        @share.get_all(@model).count.should == 0
      end
    end

    describe '.delete_all!' do
      it 'should delete all objects from all models' do
        model2 = TestDefault.entity_class

        @share.add(@model) { |obj| }
        @share.add(@model) { |obj| }
        @share.add(model2) { |obj| }

        @share.get_all(@model).count.should == 2
        @share.get_all(model2).count.should == 1

        @share.delete_all!

        @share.get_all(@model).count.should == 0
        @share.get_all(model2).count.should == 0
      end
    end
  end
end
