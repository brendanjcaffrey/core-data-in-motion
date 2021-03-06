module CDIM
  describe 'has_many relationships' do
    before do
      CDIM::Store.shared.delete_all!

      @manager = Manager.create
    end

    it 'should create a getter and setter for the children' do
      @manager.employees.count.should == 0
      lambda { @manager.employees = [Employee.create, Employee.create] }.should.change { @manager.employees.count }
    end

    it 'should raise an error when you try to set a non-employee' do
      lambda { @manager.employees = ['not an employee'] }.should.raise(Exception)
    end

    it 'should allow you to build objects' do
       employee = @manager.employees.build
       employee.is_a?(Employee).should.be.true
       employee.should.be.a.new_record?
    end

    describe 'create' do
      it 'should allow you to create objects' do
        lambda { @manager.employees.create }.should.change { Employee.all.count }
        @manager.employees.first.is_a?(Employee).should.be.true
      end

      it 'should return the created object' do
        @manager.employees.create.managed_object.should == Employee.all.first.managed_object
      end
    end

    describe '<<' do
      it 'should work' do
        lambda { @manager.employees << Employee.create }.should.change { @manager.employees.count }
      end

      it 'should allow you to chain it by returning the collection' do
        collection = @manager.employees.<<(Employee.create)
        collection.count.should == 1
        collection.first.should == @manager.employees.first
      end

      it 'should allow you to use << with an array' do
        emp1 = Employee.create
        emp2 = Employee.create
        emp1.should.not == emp2

        @manager.employees << [emp1, emp2]
        @manager.employees.count.should == 2
      end

      it 'should only allow unique additions' do
        emp1 = Employee.create
        emp2 = Employee.create

        @manager.employees = [emp1, emp2]
        lambda { @manager.employees << emp1 << emp2 }.should.not.change { @manager.employees.count }
        Employee.all.first.managed_object.should == emp1.managed_object
        lambda { @manager.employees << Employee.all.first }.should.not.change { @manager.employees.count }
      end
    end

    describe 'count' do
      it 'should return the correct count' do
        lambda { @manager.employees << Employee.create }.should.change { @manager.employees.count }
        lambda { @manager.employees << Employee.create }.should.change { @manager.employees.count }
        @manager.employees.count.should == 2
      end

      it 'should be empty? only if the count is zero' do
        @manager.employees.empty?.should == true
        lambda { @manager.employees << Employee.create }.should.change { @manager.employees.empty? }
      end
    end

    describe 'clear' do
      it 'should remove the relationships without deleteing the records' do
        @manager.employees << Employee.create
        Employee.all.count.should == 1

        lambda { @manager.employees.clear }.should.change { @manager.employees.count }
        Employee.all.count.should == 1
        Employee.all.first.manager.should == nil
      end
    end

    describe 'destroy' do
      it 'should completely destroy whatever is passed into it' do
        employee = @manager.employees.create
        lambda { @manager.employees.delete(employee) }.should.change { Employee.all.count }
      end

      it 'should remove it from the employees array' do
        employee = @manager.employees.create
        lambda { @manager.employees.delete(employee) }.should.change { @manager.employees.count }
      end

      it 'should return the collection to allow chaining' do
        @manager.employees << Employee.create << Employee.create
        collection = @manager.employees.destroy(@manager.employees.first)
        collection.count.should == 1
        collection.first.should == @manager.employees.first
      end

      it 'should remove an object even if it hasn\'t been saved' do
        employee = @manager.employees.build
        @manager.employees.count.should == 1

        @manager.employees.delete(employee)
        @manager.employees.count.should == 0
      end
    end

    describe 'destroy_all' do
      it 'should remove all children associated with the parent' do
        untouched = Employee.create

        @manager.employees << Employee.create << Employee.create
        @manager.employees.destroy_all

        Employee.all.count.should == 1
        Employee.all.first.managed_object.should == untouched.managed_object
      end
    end
  end
end
