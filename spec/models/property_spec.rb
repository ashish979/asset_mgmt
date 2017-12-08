require 'spec_helper'

describe Property do
  before(:each) do
    @role1 = Role.create(name: "employee")
    @role2 = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: "hr@vinsol.com")
    @property_group = PropertyGroup.create(name: 'Laptop', company_id: @company.id)
    @property = @property_group.properties.create(name: "Size")
    @asset_type = AssetType.create(name: 'laptop' )
    @asset  = Asset.create!(asset_type_id: @asset_type.id,:status => "spare", :name => "Test Name", :brand => "HP", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @property.stub(:update_asset_properties)
    @assets = [@asset]
    @asset_type.property_groups << @property_group
  end
 
  describe "validation" do 
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:property_group) }
    it { should validate_uniqueness_of(:name).scoped_to(:property_group_id).case_insensitive }
  end
  
  describe "associations" do
    it { should belong_to(:company) }
    it { should belong_to(:property_group) }
    it { should have_many(:asset_properties).dependent(:destroy) }
    it { should have_many(:assets).through(:asset_properties) }
    it { should have_many(:associated_audits).class_name(Audited.audit_class.name) }
  end

  describe "after_create #update_asset_properties" do 
    before do 
      @property1 = @property_group.properties.new(name: "color")
    end
    
    it "should receive update_asset_properties" do 
      @property1.should_receive(:update_asset_properties)
      @property1.save
    end
    
    it "should create properties for asset" do 
      prop = @asset.properties.count
      @property1.save
      @asset.properties.count.should eq(prop+1)
    end

    it "property1.id should eq property_id of asset_property" do 
      @property1.save
      @asset.asset_properties.last.property_id.should eq(@property1.id)
    end
    
  end

  describe 'auto_strip_attributes' do
    before do 
      @property2 = @property_group.properties.new(name: "  Test  ")
    end

    it "valid? should return false if it find name is present in db after strip" do
      property = @property_group.properties.new(name: "  Size  ")
      property.valid?.should eq(false) 
    end  

    it 'should strip white space from start and end of property name' do
      @property2.valid?
      @property2.name.should eq('Test')
    end
  end  

end
