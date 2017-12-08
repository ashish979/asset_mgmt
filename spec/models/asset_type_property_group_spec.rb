require 'spec_helper'

describe AssetTypePropertyGroup do 
  
  it_should 'use asset_type_property_group manage properties'

  before(:each) do
    @role = Role.create(name: "employee")
    @role1 = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: "hr@vinsol.com")
    @employee = Employee.create!(employee_id: "52", name: "Jagdeep Singh", email: "jagdeep.singh@vinsol.com", company_id: @company.id)
    @asset_type = AssetType.create(name: 'laptop')
    @asset = Asset.create!(asset_type_id: @asset_type.id,:status => "spare", :name => "Test Name", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :brand => "hp", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @property_group = PropertyGroup.create(name: "test", company_id: @company.id)
    @property = Property.create!(name: "ram", property_group_id: @property_group.id)
    @property_group1 = PropertyGroup.create(name: "demo", company_id: @company.id)
    @property1 = Property.create!(name: "size", property_group_id: @property_group1.id)
    @model_obj = AssetTypePropertyGroup.new(property_group_id: @property_group1.id, asset_type_id: @asset_type.id)
    @asset_property = AssetProperty.create(asset_id: @asset.id, property_id: @property.id, property_group_id: @property_group.id, value: "red")
    @assets = [@asset]
    @properties = [@property1]
    @property_groups = [@property_group]
    @asset_properties = [@asset_property]
  end
  
  describe "associations" do
    it { should belong_to(:asset_type) }
    it { should belong_to(:property_group) }
  end

end