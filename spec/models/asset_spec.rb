require 'spec_helper'

describe Asset do 

  it_should 'use restrictive destroy'
  it_should 'use asset manage_property_groups'
  it_should 'use asset status_machine'
  it_should 'use barcode module'
  it_should 'use taggable module'

  let(:ticket) {mock_model(Ticket)}

  before(:each) do
    @role = Role.create(name: "employee")
    @role1 = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: "hr@vinsol.com")
    @employee = Employee.create!(employee_id: "52", name: "Jagdeep Singh", email: "jagdeep.singh@vinsol.com", company_id: @company.id)
    @asset_type = AssetType.create(name: 'laptop')
    @asset = Asset.create!(asset_type_id: @asset_type.id,:status => "spare", :name => "Test Name", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :brand => "hp", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @assignments = @employee.assignments
    @property_group = PropertyGroup.create(name: "test", company_id: @company.id)
    @assets = [@asset]
    @property_groups = [@property_group]
  end

  describe ".audited" do 
    it { should have_many(:audits).class_name(Audited.audit_class.name) }

    it "should have auditing_enabled true" do 
      Asset.auditing_enabled.should eq(true)
    end

    it "should have audit associated with" do 
      Asset.audit_associated_with.should eq(:company)
    end

    it "should not include audited column in non_audited_columns" do 
      Asset.non_audited_columns.should_not include(:name, :status, :deleted_at, :vendor, :brand, :serial_number, :purchase_date, :description,:cost,:additional_info)
    end

    it "should have audited_column which are in only optons" do 
      @asset.audited_attributes.keys.should eq(["name", "status", "cost", "serial_number", "purchase_date", "additional_info", "description", "vendor", "deleted_at", "brand"])
    end
  end

  describe "default_scope" do 
    it "should use deleted_at for default_scope" do
      Asset.all.to_sql.should == Asset.where(deleted_at: nil).to_sql
    end
  end

 
  describe "validation" do 
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:purchase_date) }
    it { should validate_presence_of(:vendor) }
    it { should validate_presence_of(:brand) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:cost) }
    it { should validate_presence_of(:asset_type_id) }
    it { should validate_presence_of(:serial_number) }
    it { should validate_uniqueness_of(:serial_number) }
    it { should validate_numericality_of(:cost) }
  end

  describe "validate purchase_date" do 
    context "Date is valid" do 
      it "should be valid" do 
        @asset.purchase_date = DateTime.now - 2
        @asset.should be_valid  
      end
    end

    context "Invalid date" do 
      it "should not be valid" do
        @asset.purchase_date = DateTime.now + 2
        @asset.should_not be_valid
      end
    end
  end

  describe "associations" do
    it { should have_many(:assignments) }
    it { should have_many(:file_uploads) }
    it { should have_many(:employees).through(:assignments) }
    it { should have_many(:asset_properties).dependent(:destroy) }
    it { should have_many(:properties).through(:asset_properties) } 
    it { should have_many(:property_groups).through(:asset_properties) }
    it { should have_many(:active_assignments).class_name('Assignment') }
    it { should have_many(:tickets).class_name('Ticket') }
    it { should have_many(:comments) }

    it { should belong_to(:company) }
    it { should belong_to(:asset_type) }
  end

  describe "accepts_nested_attributes_for" do 
    it { should accept_nested_attributes_for(:file_uploads).allow_destroy(true) }
  end

  describe "before destroy #destroyable?" do
    it "should_receive destroyable?" do
      @asset.should_receive(:destroyable?).and_return(false)
      @asset.destroy
    end

    it "should not destroy asset" do 
      @asset.destroy.should eq(false)
    end
  end

  describe ".search" do
    before do 
      @assets.stub(:includes).with(:asset_type).and_return(@assets)
    end

    it "should_receive search_conditions" do 
      Asset.should_receive(:search_conditions).with(nil, @asset.status, nil, nil, nil)
      Asset.search(nil, @asset.status, nil, nil, nil, nil)
    end

    describe "should_receive where" do 
      context "only asset present" do 
        it "should_receive where" do 
          Asset.should_receive(:where).with(["1 AND (assets.name like ? OR assets.serial_number like ?)", "%Test Name%", "%Test Name%"]).and_return(@assets)
          Asset.search(@asset.name, nil, nil, nil, nil, nil)
        end
      end

      context "only status present" do 
        it "should_receive where" do 
          Asset.should_receive(:where).with(["1 AND assets.status = ?", @asset.status]).and_return(@assets)
          Asset.search(nil, @asset.status, nil, nil, nil, nil)
        end
      end

      context "only asset_type_id present" do 
        it "should_receive where" do 
          Asset.should_receive(:where).with(["1 AND assets.asset_type_id = ?", @asset.asset_type_id]).and_return(@assets)
          Asset.search(nil, nil, @asset.asset_type_id, nil, nil, nil)
        end
      end

      context "asset name and asset type both present" do 
        it "@asset should_receive where" do 
          Asset.should_receive(:where).with(["1 AND (assets.name like ? OR assets.serial_number like ?) AND assets.asset_type_id = ?", "%#{@asset.name}%", "%#{@asset.name}%", @asset.asset_type_id]).and_return(@assets)
          Asset.search(@asset.name, nil, @asset.asset_type_id, nil, nil, nil)
        end
      end

      context "asset name and status both present" do 
        it "@asset should_receive where" do 
          Asset.should_receive(:where).with(["1 AND (assets.name like ? OR assets.serial_number like ?) AND assets.status = ?", "%#{@asset.name}%", "%#{@asset.name}%", @asset.status]).and_return(@assets)
          Asset.search(@asset.name, @asset.status, nil, nil, nil, nil)
        end
      end

      context "asset name and status and asset type present but not employee" do 
        it "Asset should_receive where" do 
          Asset.should_receive(:where).with(["1 AND (assets.name like ? OR assets.serial_number like ?) AND assets.asset_type_id = ? AND assets.status = ?", "%#{@asset.name}%", "%#{@asset.name}%", @asset.asset_type_id, @asset.status]).and_return(@assets)
          Asset.search(@asset.name, @asset.status, @asset.asset_type_id, nil, nil, nil)
        end
      end

      context "name and employee_id is present" do 
        # before do 
        #   Asset.stub(:where).with(["1 AND assets.name like ?", "%#{@asset.name}%"]).and_return(@assets)
        #   @assets.stub(:joins).with(:assignments => :employee).and_return(@assets)      
        #   @assets.stub(:where).with("asset_employee_mappings.date_returned is NULL").and_return(@assets)
        # end
        # it "Asset should_receive where" do 
        #   Asset.should_receive(:where).with(["1 AND assets.name like ?", "%#{@asset.name}%"]).and_return(@assets)
        # end   

        # it "should_receive joins" do 
        #   @assets.should_receive(:joins).with(:assignments => :employee).and_return(@assets)      
        # end

        # it "should_receive where" do 
        #   @assets.should_receive(:where).with("asset_employee_mappings.date_returned is NULL").and_return(@assets)
        # end
        # after do 
        #   Asset.search(@asset.name, nil, nil, nil, nil, @employee.employee_id)
        # end
      end

      context "name and employee name is present" do 
        # before do 
        #   Asset.stub(:where).with(["1 AND assets.name like ?", "%#{@asset.name}%"]).and_return(@assets)
        #   @assets.stub(:joins).with(:assignments => :employee).and_return(@assets)      
        #   @assets.stub(:where).with(employees: { name: "%#{@employee.name}%"}).and_return(@assets)
        # end

        # it "Asset should_receive where" do 
        #   Asset.should_receive(:where).with(["1 AND assets.name like ?", "%#{@asset.name}%"]).and_return(@assets)
        # end   

        # it "should_receive joins" do 
        #   @assets.should_receive(:joins).with(:assignments => :employee).and_return(@assets)      
        # end

        # it "should_receive where" do 
        #   @assets.should_receive(:where).with(employees: { name: "%#{@employee.name}%"}).and_return(@assets)
        # end

        # after do 
        #   Asset.search(@asset.name, nil, nil, nil, nil, @employee.name)
        # end
      end

      context "status and employee_id is present" do 
        it "@asset should_receive where" do 
          Asset.should_receive(:where).with(["1 AND assets.status = ?", @asset.status]).and_return(Asset.all)
          Asset.search(nil, @asset.status, nil, nil, nil, @employee.employee_id)
        end   
      end

      context "status and employee name is present" do 
        it "@asset should_receive where" do 
          Asset.should_receive(:where).with(["1 AND assets.status = ?", @asset.status]).and_return(Asset.all)
          Asset.search(nil, @asset.status, nil, nil, nil, @employee.name)
        end   
      end

      context "only to are present" do 
        it "should_receive date_filter" do 
          Asset.should_receive(:where).with(["1 AND DATE(purchase_date) <= ?", Date.today]).and_return(@assets)
          Asset.search(nil, nil, nil, nil, Date.today, nil)
        end
      end

      context "only from are present" do 
        it "should_receive date_filter" do 
          Asset.should_receive(:where).with(["1 AND DATE(purchase_date) >= ?", Date.today]).and_return(@assets)
          Asset.search(nil, nil, nil, Date.today, nil, nil)
        end
      end

      context "all parameters are present" do 
        it "should_receive where" do 
          Asset.should_receive(:where).with(["1 AND (assets.name like ? OR assets.serial_number like ?) AND assets.asset_type_id = ? AND assets.status = ? AND DATE(purchase_date) <= ? AND DATE(purchase_date) >= ?", "%#{@asset.name}%", "%#{@asset.name}%", @asset.asset_type_id, @asset.status, Date.today, Date.today-1.day]).and_return(Asset.all)
          Asset.search(@asset.name, @asset.status, @asset.asset_type_id, Date.today-1.day, Date.today, @employee.name)
        end   
      end
    end

  end

  describe "#assigned_employee" do
    before do 
      @asset.stub(:assignments).and_return(@assignments)
    end 

    describe "should_receive methods" do
      it "should receive assignments" do 
        @asset.should_receive(:assignments).and_return(@assignments)
      end

      after do 
        @asset.assigned_employee
      end
    end

    context "assets is assigned" do 
      before do 
        @assignments.stub(:last).and_return(@assignments)
        @assignments.stub(:employee).and_return(@employee)
      end
      it "should return employee" do 
        @asset.assigned_employee.should eq(@employee)
      end
    end

    context "assets is not assigned" do 
      before do 
        @employee.assignments.delete_all
      end
      it "should return employee" do 
        @asset.assigned_employee.should be_blank
      end
    end
  end

  describe "#retired?" do 
    context "asset retired" do 
      before do 
        @asset.update_attribute(:deleted_at, Time.now)
      end
      it "should return true" do 
        @asset.retired?.should eq(true)
      end
    end

    context "asset not retired" do 
      it "should return false" do 
        @asset.retired?.should eq(false)
      end
    end
  end

  describe "#display_name" do 
    it "should return id-name" do 
      @asset.display_name.should eq("#{@asset.id}-#{@asset.name}")
    end
  end

  describe "#active_assigned_employee" do
    before do 
      @asset.stub(:active_assignments).and_return(@assignments)
      @assignments.stub(:last).and_return(@assignments)
      @assignments.stub(:employee).and_return(@employee)
    end 

    describe "should_receive methods" do
      it "should receive assignments" do 
        @asset.should_receive(:active_assignments).and_return(@assignments)
      end

      it "should receive last" do 
        @assignments.should_receive(:last).and_return(@assignments)
      end

      it "should receive employee" do 
        @assignments.should_receive(:employee).and_return(@employee)
      end

      after do 
        @asset.active_assigned_employee
      end
    end

    context "assets is assigned" do 
      before do 
        @assignments.stub(:last).and_return(@assignments)
        @assignments.stub(:employee).and_return(@employee)
      end
      it "should return employee" do 
        @asset.active_assigned_employee.should eq(@employee)
      end
    end

    context "assets is not assigned" do 
      before do 
        @assignments.stub(:last).and_return(@assignments)
        @assignments.stub(:employee).and_return([])
      end
      it "should return employee" do 
        @asset.active_assigned_employee.should be_blank
      end
    end
  end

  describe ".search_conditions" do 
    context "only name present" do 
      it "should eq to name query" do 
        Asset.search_conditions(@asset.name, nil, nil, nil, nil).should eq(["1 AND (assets.name like ? OR assets.serial_number like ?)", "%#{@asset.name}%", "%#{@asset.name}%"])
      end
    end

    context "only status present" do 
      it "should eq to status query" do 
        Asset.search_conditions(nil, @asset.status, nil, nil, nil).should eq(["1 AND assets.status = ?", @asset.status])
      end
    end

    context "only asset type present" do 
      it "should eq to asset type query" do 
        Asset.search_conditions(nil, nil, @asset.asset_type_id, nil, nil).should eq(["1 AND assets.asset_type_id = ?", @asset.asset_type_id])
      end
    end

    context "only from present" do 
      it "should eq to from query" do 
        Asset.search_conditions(nil, nil, nil, Date.today, nil).should eq(["1 AND DATE(purchase_date) >= ?", Date.today])
      end
    end

    context "only to present" do 
      it "should eq to to date query" do 
        Asset.search_conditions(nil, nil, nil, nil, Date.today).should eq(["1 AND DATE(purchase_date) <= ?", Date.today])
      end
    end
  end

  describe "scpoe retired_assets" do
    context "asset not retired" do 
      it "should return blank" do 
        Asset.retired_assets(@company).should eq([])
      end
    end

    context "asset retired" do 
      before do 
        @asset.update_attributes(:deleted_at => Time.now)
      end

      it "should return retired assets" do 
        Asset.retired_assets(@company).should eq([@asset])
      end
    end

    describe "should_receive methods" do 
      before do 
        Asset.stub(:unscoped).and_return(@assets)
        @assets.stub(:where).and_return(@assets)
        @assets.stub(:not).with(deleted_at: nil).and_return(@assets)
        @assets.stub(:where).with(company_id: @company.id).and_return(@assets)
      end

      it "should_receive unscoped" do 
        Asset.should_receive(:unscoped).and_return(@assets)
      end

      it "should_receive where" do 
        @assets.should_receive(:where).and_return(@assets)
      end

      it "should_receive not" do 
        @assets.should_receive(:not).with(deleted_at: nil).and_return(@assets)
      end

      it "should_receive where with company_id" do 
        @assets.should_receive(:where).with(company_id: @company.id).and_return(@assets)
      end

      after do
        Asset.retired_assets(@company)
      end
    end
  end

  describe "#has_tickets?" do 
    context "tickets present" do 
      before do 
        @asset.stub(:tickets).and_return(ticket)
      end

      it "should return true" do 
        @asset.has_tickets?.should eq(true)
      end
    end
    
    context "tickets not present" do 
      before do
        @asset.stub(:tickets).and_return([])
      end

      it "should return false if tickets not present" do 
        @asset.has_tickets?.should eq(false)
      end
    end
  end

  describe "restrict_update" do 
    context "asset retired" do 
      before do 
        @asset.update_column(:deleted_at, Time.now)
      end

      it "should_receive restrict_update" do 
        @asset.should_receive(:restrict_update)
        @asset.save
      end

      context "changes has deleted_at in keys" do 
        before do 
          @asset.deleted_at = nil
        end

        it "should return true" do 
          @asset.save.should eq(true)
        end
      end

      context "changes has not deleted_at in keys" do 
        before do 
          @asset.updated_at = Time.now
        end

        it "should return false" do 
          @asset.save.should eq(false)
        end
      end
    end

    context "asset not retired" do 
      it "should_not_receive restrict_update" do 
        @asset.should_not_receive(:restrict_update)
        @asset.save
      end
    end
  end

end