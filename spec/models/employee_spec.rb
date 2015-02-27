require 'spec_helper'

describe Employee do 

  it_should 'use devisable module'

	before(:each) do
    @role = Role.create(name: "admin")
    @role1 = Role.create(name: "employee")
    @company = Company.create(name: "Vinsol", email: "hr@vinsol.com")
		@employee = Employee.create!(employee_id: "52", name: "Jagdeep Singh", email: "jagdeep.singh@vinsol.com", company_id: @company.id)
    @asset_type = AssetType.create(name: 'laptop')
    @asset = Asset.create!(asset_type_id: @asset_type.id, :status => "spare", :name => "Test Name", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :brand => "HP", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @assignment = Assignment.create!(asset_id: @asset.id, employee_id: @employee.id, assignment_type: "Temporary", date_issued: DateTime.now - 6)
    @employees = [@employee]
    @assignments = [@assignment]
    @employee.roles << @role
  end
	
  describe "vaidations" do 
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:employee_id).with_message(/ID cannot be blank/) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_uniqueness_of(:employee_id).scoped_to(:company_id).with_message(/ID has already being taken/) }
    it { should validate_numericality_of(:employee_id).only_integer.with_message(/ID must be positive/) }
    it { should allow_value('test@example.com').for(:email ) }
    it { should allow_value('test@example.co.in').for(:email ) }
    it { should_not allow_value('test@example').for(:email ) }
  end

  describe "associations" do 
    it { should have_many(:assignments) }
    it { should have_many(:file_uploads) }
    it { should have_many(:assets).through(:active_assignments) }
    it { should have_many(:comments) }
    it { should have_many(:active_assignments).class_name('Assignment') }
    it { should have_many(:returned_assignments).class_name('Assignment') }
    it { should belong_to(:company) }
  end

  describe "delegation" do 
    it { should delegate(:name).to(:company).with_prefix }
  end
	
	describe "Validation of greater_than for employee_id" do 
    context "negative employee_id" do 
      it "should not be valid" do
        @employee.employee_id = -4
        @employee.should_not be_valid
      end
    end

    context "positive employee_id" do
      it "should be valid" do 
        @employee.should be_valid
      end
    end
  end	

  describe "#can_be_disabled?" do 
    before do 
      @assignments = @employee.assignments
      @employees = [@employee]
    end

    context "no assignments" do
      before do 
        @employee.stub(:assignments).and_return([])
      end

      it "should return true" do
        @employee.can_be_disabled?.should be_true
      end
    end

    context "assignments" do
      context "have some assignments" do 
        before do 
          @employee.assignments.update_all(date_returned: nil)
        end
        it "should return false" do
          @employee.can_be_disabled?.should be_false
        end  
      end

      context "returned all assignment" do 
        before do 
          @employee.assignments.update_all(date_returned: Time.now)
        end
        it "should return true" do
          @employee.can_be_disabled?.should be_true
        end  
      end
    end
  end

  describe "scope enabled" do 
    describe "should_receive methods" do
      it "should_receive where" do 
        Employee.should_receive(:where).with(company_id: @company)
        Employee.enabled(@company)
      end
    end

    context "@employee is disabled" do 
      before do 
        @company.employees.update_all(deleted_at: Time.now)
      end
      it "should return blank" do 
        Employee.enabled(@company).should be_blank
      end
    end

    context "@employee is enabled" do 
      it "should return all enabled employee" do 
        Employee.enabled(@company).should eq(@company.employees)
      end
    end
  end
	
  describe "scope disabled" do
    describe "should_receive methods" do
      before do 
        Employee.stub(:unscoped).and_return(@employees)
        @employees.stub(:where).and_return(@employees)
        @employees.stub(:not).with(deleted_at: nil).and_return(@employees)
        @employees.stub(:where).with(company_id: @company.id).and_return(@employees)
      end

      it "should_receive unscoped" do 
        Employee.should_receive(:unscoped).and_return(@employees)
      end
      
      it "should_receive where" do 
        @employees.should_receive(:where).and_return(@employees)
      end

      it "should_receive not" do 
        @employees.should_receive(:not).with(deleted_at: nil).and_return(@employees)
      end

      it "should_receive where with company_id" do 
        @employees.should_receive(:where).with(company_id: @company.id).and_return(@employees)
      end

      after do 
        Employee.disabled(@company)
      end
    end

    context '@employee is disabled' do 
      before do 
        @employee.update_attribute(:deleted_at, Time.now)
      end
      it "should return the disabled @employee" do 
        Employee.disabled(@company).should eq([@employee])
      end
    end

    context '@employee is enabled' do 
      it "should return the blank" do 
        Employee.disabled(@company).should be_blank
      end
    end
  end

  describe "#enabled?" do 
    context "employee enabled" do 
      it "should return true" do 
        @employee.enabled?.should eq(true)
      end
    end

    context "employee disabled" do 
      before do 
        @employee.update_attribute(:deleted_at, Time.now)
      end
      it "should return false" do 
        @employee.enabled?.should eq(false)
      end
    end
  end

  describe "#disabled?" do 
    context "employee enabled" do 
      it "should return false" do 
        @employee.disabled?.should eq(false)
      end
    end

    context "employee disabled" do 
      before do 
        @employee.update_attribute(:deleted_at, Time.now)
      end
      it "should return true" do 
        @employee.disabled?.should eq(true)
      end
    end
  end

  describe "has_soft_deletion" do 
    it "should have a default scope" do 
      Employee.all.to_sql.should == Employee.where(deleted_at: nil).to_sql
    end
  end

  describe "alias_atttribute admin" do

    it "should not raise error" do 
      expect{ @employee.admin? }.to_not raise_error
    end

    context "is_admin true" do 
      before do 
        @employee.update_attribute(:is_admin, true)
      end

      it "should return the value of is_admin" do 
        @employee.admin?.should eq(true)
      end
    end

    context "is_admin false" do 
      before do 
        @employee.update_attribute(:is_admin, false)
      end

      it "should return the value of is_admin" do 
        @employee.admin?.should eq(false)
      end
    end
  end

  describe "#has_role?" do
    it "should return true if role is matched" do 
      @employee.has_role?(:admin).should eq(true)
    end

    it "should return false if role is not matched" do 
      @employee.has_role?(:super_admin).should eq(false)
    end
  end 

  describe "#has_any_role?" do
    it "should return true if role is matched against ROLES array" do 
      @employee.has_any_role?.should eq(true)
    end

    it "should return false if role is not matched" do 
      @employee.roles.delete_all
      @employee.has_any_role?.should eq(false)
    end
  end 

  describe "before_create assign_default_role" do 
    before do 
      @employee1 = Employee.create!(employee_id: "55", name: "Test User", email: "test.user@vinsol.com", company_id: @company.id)
    end

    it "should have a role employee" do 
      @employee1.has_role?(:employee).should eq(true)
    end
  end

end	
