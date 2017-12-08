require 'spec_helper'

describe PropertyGroup do
  before(:each) do
    @role1 = Role.create(name: "employee")
    @role2 = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: "hr@vinsol.com")
    @property_group = PropertyGroup.create(name: 'Laptop', company_id: @company.id)
    @property = @property_group.properties.create(name: "Size")
    @asset_type = AssetType.create(name: 'laptop' )
    @asset  = Asset.create!(asset_type_id: @asset_type.id ,:status => "spare", :name => "Test Name", :brand => "HP", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @property.stub(:update_asset_properties)
  end

  describe "validation" do 
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:company_id).case_insensitive }
  end

  describe "associations" do
    it { should belong_to(:company) }
    it { should have_many(:properties).dependent(:destroy) }
    it { should have_many(:assets).through(:asset_properties) }
    it { should have_many(:asset_properties) }
    it { should have_many(:asset_type_property_groups).dependent(:destroy) }
    it { should have_many(:asset_types).through(:asset_type_property_groups) }
  end

  describe 'auto_strip_whitespace' do
    before do 
      @property_group2 = PropertyGroup.new(:name => '  Test  ')
    end

    it "valid? should return false if it find name is present in db after strip" do
      property_group = PropertyGroup.new(:name => '    Laptop     ', company_id: @company.id)
      property_group.valid?.should eq(false) 
    end  

    it 'should strip white space from start and end of property_group name and then validate it' do
      @property_group2.valid?
      @property_group2.name.should eq('Test')
    end
  end
  
end
