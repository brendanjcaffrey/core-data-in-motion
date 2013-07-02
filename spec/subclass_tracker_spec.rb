module CDIM
  describe SubclassTracker do
    it 'should track all direct subclasses' do
      Model.subclasses.should.include TestModel
      Model.subclasses.should.include TestDefault
      Model.subclasses.should.include TestTimestamp
      Model.subclasses.should.include TestRequired
      Model.subclasses.should.include TestEnum
      Model.subclasses.should.include Manager
      Model.subclasses.should.include Employee
      Model.subclasses.should.include Device
      Model.subclasses.should.include Owner
    end
  end
end
