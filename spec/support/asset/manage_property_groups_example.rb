shared_examples_for 'use asset manage_property_groups' do

  describe "#assign_property_groups" do 
    before do 
      @asset1 = Asset.new(asset_type_id: @asset_type.id,:status => "spare", :name => "Name", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf7sss89IU", :brand => "hp", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
      Asset.any_instance.stub(:create_barcode).and_return(true)
    end
    context "asset type is blank" do 
      it "should_receive asset_type" do 
        @asset1.should_receive(:asset_type).and_return([])
        @asset1.save
      end
    end

    context "proerty groups is blank" do 
      before do 
        @asset_type.stub(:property_groups).and_return([])
      end

      it "should_receive asset_type" do 
        @asset1.should_receive(:asset_type).exactly(2).times.and_return(@asset_type)
      end

      after do 
        @asset1.save
      end
    end
  end

end