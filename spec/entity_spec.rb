module CDIM
  describe Entity do
    before do
      CDIM::Store.shared.delete_all!

      @employee_entity = (Model.entity_class_prefix + 'Employee').constantize
      @default_entity = (Model.entity_class_prefix + 'TestDefault').constantize
    end

    describe 'entity_description' do
      it 'should be an instance of NSEntityDescription' do
        TestModel.entity_description.should.be.a.instance_of NSEntityDescription
      end

      it 'should have the correct name' do
        Employee.entity_description.name.should == @employee_entity.to_s
        TestDefault.entity_description.name.should == @default_entity.to_s
      end

      it 'should have the correct managed object class name' do
        Employee.entity_description.managedObjectClassName.should == @employee_entity.to_s
        TestDefault.entity_description.managedObjectClassName.should == @default_entity.to_s
      end

      it 'should have the correct number of properties' do
        TestModel.entity_description.properties.count.should == 7
        TestDefault.entity_description.properties.count.should == 1
        Employee.entity_description.properties.count.should == 2
      end
    end

    it 'should reveal the entity class name' do
      Employee.entity_class.should == @employee_entity
      TestDefault.entity_class.should == @default_entity
    end

    it 'should give the managed subclass a method revealing it\'s corresponding managed class' do
      @employee_entity.wrapper_class.should == Employee
      @default_entity.wrapper_class.should == TestDefault
    end
  end
end
