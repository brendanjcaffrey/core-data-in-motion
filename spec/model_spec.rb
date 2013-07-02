module CDIM
  describe Model do
    before do
      CDIM::Store.shared.delete_all!
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
  end
end
