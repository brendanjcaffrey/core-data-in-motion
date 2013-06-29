module CDIM
  describe 'has_one relationships' do
    before do
      CDIM::Store.shared.delete_all!

      @device = Device.create
    end

    it 'should allow you to create the other object' do
      lambda { @device.create_owner(:name => 'test') }.should.change { Owner.all.count }
      @device.owner.name.should == 'test'
    end

    it 'should allow you to build the other object without saving and save it later' do
      lambda { @device.build_owner(:name => 'test') }.should.not.change { Owner.all.count }
      @device.owner.name.should == 'test'

      lambda { @device.owner.save }.should.change { Owner.all.count }
      Owner.all.last.name.should == 'test'
    end

    it 'should delete the association on building a new object' do
      @device.create_owner(:name => 'test')
      Device.all.first.owner.should.not == nil

      @device.build_owner(:name => 'test')
      Device.all.first.owner.should == nil
    end

    it 'should allow you to set the other object manually' do
      owner = Owner.build(:name => 'the owner')
      puts @device.owner.inspect
      lambda { @device.owner = owner }.should.change { @device.owner }
    end

    it 'should allow you to set the other object through create and build' do
      device = Device.create(:owner => Owner.create)
      device.owner.should.not == nil

      device = Device.build(:owner => Owner.all.first)
      device.owner.should.not == nil
    end

    it 'should persist the changes across save' do
      @device.create_owner({})
      Device.all.last.owner.managed_object.should == @device.owner.managed_object
    end

    it 'should be able to set the child to nil' do
      @device.create_owner(:name => 'test')
      @device.owner.should != nil
      @device.owner = nil
      @device.owner.should == nil
    end

    it 'should save the child object when set if the parent isn\'t dirty' do
      owner = Owner.new
      owner.name = 'blah'

      lambda { @device.owner = owner }.should.change { Owner.all.count }
      Owner.all.first.name.should == 'blah'
    end
  end
end
