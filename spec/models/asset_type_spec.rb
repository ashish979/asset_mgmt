require 'spec_helper'

describe AssetType do 
  
  it_should 'use asset_type restrictive destroy'

  before(:each) do
    @role1 = Role.create(name: "employee")
    @role2 = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: "hr@vinsol.com")
    @asset_type = AssetType.create(name: 'laptop')
    @asset = Asset.create!(asset_type_id: @asset_type.id,:status => "spare", :name => "Test Name", :brand => "HP", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @assets = [@asset]
  end

  describe "associations" do
    it { should belong_to(:company) }
    it { should have_many(:assets)}
    it { should have_many(:asset_type_property_groups).dependent(:destroy) }
    it { should have_many(:property_groups).through(:asset_type_property_groups) }
  end

  describe "validation" do 
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:company_id) }
  end

  describe "accept_nested_attributes_for" do 
    it { should accept_nested_attributes_for(:asset_type_property_groups).allow_destroy(true) }
  end

end
