shared_examples_for 'use restrictive destroy' do

  describe "before destroy #destroyable?" do
    before do 
      @obj = described_class.new
    end

    it "should_receive destroyable?" do
      @obj.should_receive(:destroyable?).and_return(false)
      @obj.destroy
    end

    it "should not destroy asset" do 
      @obj.destroy.should eq(false)
    end
  end

end