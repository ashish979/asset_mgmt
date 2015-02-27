require 'spec_helper'

describe AssetProperty do 
  before(:each) do
    @role = Role.create(name: "employee")
    @role1 = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: "hr@vinsol.com")
    @employee = Employee.create!(employee_id: "52", name: "Jagdeep Singh", email: "jagdeep.singh@vinsol.com", company_id: @company.id)
    @asset_type = AssetType.create(name: 'laptop')
    @asset = Asset.create!(asset_type_id: @asset_type.id,:status => "spare", :name => "Test Name", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :brand => "hp", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @property_group = PropertyGroup.create(name: "test", company_id: @company.id)
    @property = Property.create!(name: "ram", property_group_id: @property_group.id)
    @assets = [@asset]
    @property_groups = [@property_group]
    @asset_property = AssetProperty.create!(property_id: @property.id, property_group_id: @property_group.id, asset_id: @asset.id)
  end

  describe "validation" do 
    before do 
      AssetProperty.any_instance.stub(:assign_property_group)
    end

    it { should validate_presence_of(:asset) }
    it { should validate_presence_of(:property) }
    it { should validate_presence_of(:property_group) }
    it { should validate_uniqueness_of(:asset).scoped_to(:property_id, :property_group_id).with_message(/There is already a record with same property and property group for this asset/) }
  end
  
  describe "associations" do
    it { should belong_to(:property) }
    it { should belong_to(:asset) }
    it { should belong_to(:property_group) }
  end

  describe ".audited" do 
    it { should have_many(:audits).class_name(Audited.audit_class.name) }

    it "should have auditing_enabled true" do 
      AssetProperty.auditing_enabled.should eq(true)
    end

    it "should have audit associated with" do 
      AssetProperty.audit_associated_with.should eq(:property)
    end

    it "should not include audited column in non_audited_columns" do 
      AssetProperty.non_audited_columns.should_not include(:value)
    end

    it "should have audited_column which are in only optons" do 
      @asset_property.audited_attributes.keys.should eq(["value"])
    end
  end

  describe "before_save assign_property_group" do 
    context "property_group_id is not present" do 
      before do 
        @asset_property.update_column(:property_group_id, nil)
      end

      it "should set property_group_id" do 
        @asset_property.save 
        @asset_property.property_group_id.should eq(@property_group.id)
      end

      describe "should_receive methods" do 
        it "should receive assign_property_group" do 
          @asset_property.should_receive(:assign_property_group)
          @asset_property.save
        end

        it "should_receive property_group_id" do 
          @asset_property.should_receive(:property_group_id).and_return(@property_group.id)
          @asset_property.save
        end
      end
    end

    context "property_group_id is present" do 
      it "should not receive assign_property_group" do 
        @asset_property.should_not_receive(:assign_property_group)
        @asset_property.save
      end
    end
  end
end