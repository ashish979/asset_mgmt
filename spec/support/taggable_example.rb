shared_examples_for 'use taggable module' do  
  describe "associations" do
    it { should have_and_belong_to_many(:tags) }
  end

  describe "#add_tags" do
    context "tags_field is blank" do 
      before do 
        @asset1 = Asset.new(asset_type_id: @asset_type.id, :status => "spare", :name => "Test Name", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf7891IU", :brand => "HP", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info")
      end

      it "should return nil" do 
        @asset1.add_tags.should be_nil
      end
    end

    context "tags_field is present" do 
      before do 
        @asset2 = Asset.new(asset_type_id: @asset_type.id, :status => "spare", :name => "Test Name", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf7891IU", :brand => "HP", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", :tags_field => "LapTop", company_id: @company.id)
      end
      
      context "should_receive methods" do 
        before do 
          @tags = Tag.new(name: "LapTop")
          @asset2.stub(:company).and_return(@company)
          @company.stub(:tags).and_return(@tags)
          @tags.stub(:where).and_return(@tags)
          @tags.stub(:first_or_initialize).and_return(@tags)
        end
        it "should recive company" do 
          @asset2.should_receive(:company).and_return(@company)
        end
        it "company should recive tags" do 
          @company.should_receive(:tags).and_return(@tags)
        end
        it "@tags should recive where" do 
          @tags.should_receive(:where).with(name: "LapTop").and_return(@tags)
        end
        it "@tags should recive first_or_initialize" do 
          @tags.should_receive(:first_or_initialize).and_return(@tags)
        end
        
        after do 
          @asset2.save
        end
      end
        
      it "should create tags" do 
        @asset2.save
        @asset2.tags.first.name.should eq("LapTop")
      end
    end
  end

  describe "#remove_tags" do
    before do 
      @tag = @asset.tags.create!(name: 'Test')
      @tags = [@tag]
    end
    
    it "should remove  tag of asset" do 
      @asset.remove_tags(@tag.id)
      @asset.tags.count.should eq(0)
    end

    it "should not remove the tag from tag table" do 
      tag = Tag.where(name: 'Test').first
      tag.should be_present
    end

    describe "should_receive methods" do 
      before do 
        @asset.stub(:tags).and_return(@tags)
        @tags.stub(:where).with(@tag.id).and_return(true)
      end
      it "@asset should_receive tags" do
        @asset.should_receive(:tags).and_return(@tags)
      end

      it "@tags should_receive tags" do
        @tags.should_receive(:delete).with(@tag.id).and_return(true)
      end

      after do 
        @asset.remove_tags(@tag.id)
      end
    end
  end
  
  describe "attr_accessor tags_field" do
    before do 
      @asset.tags_field = "Testing attr_accessor"
    end

    describe "reader method" do 
      it "should read the tags_field" do 
        @asset.tags_field.should eq("Testing attr_accessor")
      end
    end

    describe "writer method" do 
      it "should set tags_field value" do 
        @asset.tags_field = "test"
        @asset.tags_field.should eq("test")
        @asset.tags_field.should_not eq("Testing attr_accessor")
      end
    end
  end

end