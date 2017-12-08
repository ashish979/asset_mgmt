shared_examples_for 'use asset_type_property_group manage properties' do

  describe "after_create update_asset_properties" do 
    describe "expected results" do 
      before do 
        @asset_prop = @asset.properties.count
      end

      it "should add properties to asset" do 
        @model_obj.save!
        @asset.properties.count.should eq(@asset_prop + 1)
      end

      it "should add property1 to asset_property" do 
        @model_obj.save!
        @asset.properties.last.should eq(@property1)
      end
    end

    describe "should_receive methods" do 
      before do 
        @model_obj.stub(:asset_type).and_return(@asset_type)
        @asset_type.stub(:assets).and_return(@assets)
        @asset.stub(:properties).and_return(@properties)
        @model_obj.stub(:property_group).and_return(@property_group1)
        @property_group.stub(:properties).and_return(@properties)
      end

      it "should_receive asset_type" do 
        @model_obj.should_receive(:asset_type).and_return(@asset_type)
      end

      it "should_receive assets" do 
        @asset_type.should_receive(:assets).and_return(@assets)
      end

      it "should_receive properties" do 
        @asset.should_receive(:properties).and_return(@properties)
      end

      it "should_receive property_group" do 
        @model_obj.should_receive(:property_group).and_return(@property_group1)
      end

      it "should_receive properties" do 
        @property_group1.should_receive(:properties).and_return(@properties)
      end

      after do 
        @model_obj.save
      end
    end
  end

  describe "before_destroy destroy_asset_properties" do 
    before do 
      @model_obj.save!
    end

    describe "expected results" do 
      before do 
        @asset_prop_count = @asset.asset_properties.count
      end

      it "should destroy record from asset_properties" do 
        @model_obj.destroy
        @asset.asset_properties.count.should eq(@asset_prop_count -1)
      end

      it "should not have property of property_group1" do 
        @model_obj.destroy
        @asset.properties.pluck(:id).should_not include(@property1.id)
      end
    end

    describe "should_receive methods" do 
      before do 
        @model_obj.stub(:asset_type).and_return(@asset_type)
        @asset_type.stub(:assets).and_return(@assets)
        @assets.stub(:includes).with(:asset_properties).and_return(@assets)
        @asset.stub(:asset_properties).and_return(@asset_properties)
        @asset_properties.stub(:where).with("asset_properties.property_group_id = ?", @property_group1.id).and_return(@asset_properties)
        @asset_properties.stub(:destroy_all).and_return(true)
      end

      it "should_receive asset_type" do 
        @model_obj.should_receive(:asset_type).and_return(@asset_type)
      end

      it "should_receive assets" do 
        @asset_type.should_receive(:assets).and_return(@assets)
      end

      it "should_receive includes" do 
        @assets.should_receive(:includes).with(:asset_properties).and_return(@assets)
      end
      
      it "should_receive asset_properties" do 
        @asset.should_receive(:asset_properties).and_return(@asset_properties)
      end

      it "should_receive where" do 
        @asset_properties.should_receive(:where).with("asset_properties.property_group_id = ?", @property_group1.id).and_return(@asset_properties)
      end

      it "should_receive destroy_all" do 
        @asset_properties.should_receive(:destroy_all).and_return(true)
      end

      after do 
        @model_obj.destroy
      end
    end
  end
end