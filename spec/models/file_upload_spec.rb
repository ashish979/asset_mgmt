require 'spec_helper'

describe FileUpload do 

  before(:each) do
    @role1 = Role.create(name: "employee")
    @role2 = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: "hr@vinsol.com")
    @employee = Employee.create!(employee_id: "52", name: "Jagdeep Singh", email: "jagdeep.singh@vinsol.com", company_id: @company.id)
    @asset_type = AssetType.create(name: 'laptop')
    @asset = Asset.create!(asset_type_id: @asset_type.id,:status => "spare", :name => "Test Name", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :brand => "hp", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @assignments = @employee.assignments
    @property_group = PropertyGroup.create(name: "test", company_id: @company.id)
    @assets = [@asset]
    @property_groups = [@property_group]
    @file_upload = FileUpload.create!(file_file_name: "ashutosh1.jpg", file_content_type: "image/jpeg", file_file_size: 1740546, file_updated_at: "2013-12-18 08:27:36", description: "image", asset_id: @asset.id, employee_id: @employee.id)  
  end
  
  describe "associations" do 
    it { should have_attached_file(:file) }

    it { should belong_to(:asset) }
    it { should belong_to(:uploader).class_name('Employee') }
  end

  describe "validations" do 
    it { should validate_presence_of(:description) }
    it { should validate_attachment_content_type(:file).
                allowing('image/jpeg', 'image/png', 'image/gif', 'image/jpg', 'application/pdf', 'application/docx', 'application/doc').
                rejecting('text/plain', 'text/xml') }
                
    it { should validate_attachment_size(:file).less_than(5.megabytes) }            
  end

  describe "delegation to uploader" do 
    it { should delegate(:name).to(:uploader).with_prefix }
  end

  describe "#destroyable?" do 
    context "asset retired" do 
      before do 
        @asset.update_column(:deleted_at, Time.now)
      end

      it "should return false" do 
        expect(@file_upload.destroyable?).to eq(false)
      end
    end

    context "asset not retired" do 
      it "should return true" do 
        expect(@file_upload.destroyable?).to eq(true)
      end
    end
  end

end