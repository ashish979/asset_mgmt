shared_examples_for 'use asset_statable module' do
  
  describe "scope assigned_assets" do 
    it "should return all assigned assets" do 
      Assignment.assigned_assets.should eq([@assignment])
    end
  end
  
  describe "#update_aem_asset" do 
    it "should update the status to spare" do
      @assignment.update_aem_asset
      @assignment.asset.status.should eq(Asset::STATUS["Spare"])
    end
  end

  describe "#update_status" do 
    it "should update the status to assigned" do
      @asset.status.should_not eq(Asset::STATUS["Assigned"])
      @assignment.update_status
      @assignment.asset.status.should eq(Asset::STATUS["Assigned"])
    end
  end
  
  describe "#check_asset_status" do 
    before do 
      @assignment.stub(:asset).and_return(@asset)
      @asset.stub(:assignable?).and_return(true)
    end
    
    describe "should receive methods" do 
    
      it "asset should receive asset" do 
        @assignment.should_receive(:asset).and_return(@asset)
      end

      it "@asset should_receive assignable?" do 
        @asset.should_receive(:assignable?).and_return(true)
      end

      after do
        @assignment.check_asset_status
      end
    end

    describe "return value" do 
      context "assignable?" do 
        it "should return true" do 
          @assignment.check_asset_status.should eq(true)
        end
      end

      context "can not be assigned" do 
        before do 
          @asset.stub(:assignable?).and_return(false)  
        end
        it "should return false" do 
          @assignment.check_asset_status.should eq(false)
        end
      end
    end
  end

end