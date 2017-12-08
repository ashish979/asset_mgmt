shared_examples_for 'use asset_type restrictive destroy' do

  describe "before_destroy #destroyable?" do
    context "asset type have assets" do 
      it "should return false" do 
        @asset_type.destroy.should eq(false)
      end
    end
    
    context "have only retired asset" do 
      before do 
        @asset.update_column(:deleted_at, Time.now)
      end
    
      it "should return false" do 
        @asset_type.destroy.should eq(false)
      end
    end

    context "don't have assets" do 
      before do
        @asset_type.assets.delete_all
      end

      it "should destroy the asset type" do 
        @asset_type.destroy.should eq(@asset_type)
      end
    end

    describe "should_receive methods" do 
      before do 
        Asset.stub(:unscoped).and_return(@assets)
        @assets.stub(:where).with(asset_type_id: @asset_type.id).and_return(@assets)
        @assets.stub(:blank?).and_return(false)
      end

      it "should_receive destroyable?" do 
        # @asset_type.should_receive(:destroyable?).and_return(false)
      end

      it "should_receive unscoped" do 
        Asset.should_receive(:unscoped).and_return(@assets)
      end
      
      it "should_receive where" do 
        @assets.should_receive(:where).with(asset_type_id: @asset_type.id).and_return(@assets)
      end

      it "should_receive blank?" do 
        @assets.should_receive(:blank?).and_return(false)
      end

      after do 
        @asset_type.destroy
      end
    end
  end
end