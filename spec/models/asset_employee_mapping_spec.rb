require 'spec_helper'

describe Assignment do 

  it_should 'use commentable module'
  it_should 'use asset_statable module'
  
  before(:each) do
    @role = Role.create(name: "employee")
    @role1 = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: "hr@vinsol.com")
    @employee = Employee.create!(employee_id: "52", name: "Jagdeep Singh", email: "jagdeep.singh@vinsol.com", company_id: @company.id)
    @asset_type = AssetType.create(name: 'laptop')
    @asset = Asset.create!(asset_type_id: @asset_type.id, :status => "spare", :name => "Test Name", :brand => "HP", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @assignment = Assignment.create!(asset_id: @asset.id, employee_id: @employee.id, assignment_type: "Temporary", date_issued: DateTime.now - 6)
    @comment = Comment.create(body: "test", resource_id: @assignment.id, resource_type: "Assignment")
  end
  
  describe "set table name" do 
    it "return table name" do 
      Assignment.table_name.should == "asset_employee_mappings"
    end
  end

  describe "associations" do
    it { should belong_to(:asset) }
    it { should belong_to(:employee) }
  end


  describe "validation" do 
    it { should validate_presence_of(:asset_id) }
    it { should validate_presence_of(:employee_id) }
    it { should validate_presence_of(:date_issued) }
  end

  describe "accept_nested_attributes_for comments" do 
    it { should accept_nested_attributes_for(:comments).allow_destroy(true) }
  end

  describe "validation on date_returned" do 
    context "on create" do 
      it "should not check for validation" do 
        Assignment.count.should eq(1)
      end
    end

    context "on update" do 
      it "should check for presence of date_returned" do 
        @assignment.save.should eq(false)
      end
      it "should have date returned greater than date issued" do
        @assignment.date_issued = DateTime.now + 2 
        @assignment.date_returned = DateTime.now - 2 
        @assignment.should_not be_valid
        
        @assignment.date_issued = DateTime.now - 2 
        @assignment.date_returned = DateTime.now - 1 
        @assignment.should be_valid
      end
      it "should have date_returned less than DateTime.now" do 
        @assignment.date_returned = DateTime.now + 2 
        @assignment.should_not be_valid
        
        @assignment.date_returned = DateTime.now - 1 
        @assignment.should be_valid
      end
    end

    describe "validation on date issued" do 
      it "should be less than DateTime.now" do 
        @assignment.date_returned = DateTime.now - 1
        @assignment.date_issued = DateTime.now + 2
        @assignment.should_not be_valid
        
        @assignment.date_issued = DateTime.now - 2
        @assignment.should be_valid  
      end
    end
  end

  describe "validation temporarly_assignment_date" do 
    context "on create" do 
      before do 
        Assignment.delete_all 
        @asset.update_attribute(:status, "spare")
        @assignment1 = Assignment.new(asset_id: @asset.id, employee_id: @employee.id, assignment_type: "Temporary", date_issued: DateTime.now - 6, date_returned: DateTime.now + 6)
      end
      it "should receive temporarly_assignment_date" do 
        @assignment1.should_receive(:temporarly_assignment_date)
        @assignment1.valid?
      end

      context 'assignment_type is false but expected_return_date is not nil' do 
        before do 
          @assignment1.assignment_type = "false"
          @assignment1.expected_return_date = DateTime.now
          @assignment1.valid?       
        end
        it "should_not receive errors" do 
          @assignment1.should have(0).error_on(:expected_return_date)
        end
      end

      context 'expected_return_date is blank but assignment_type is not false' do 
        before do 
          @assignment1.assignment_type = "Temporary"
          @assignment1.expected_return_date = nil
          @assignment1.valid?
        end
        it "should_not receive errors" do 
          @assignment1.should have(0).error_on(:expected_return_date)
        end
      end

      context 'assignment_type is false and date_returned is blank' do 
        before do 
          @assignment1.assignment_type = "false"
          @assignment1.expected_return_date = nil
          @assignment1.valid?
        end
        it "should receive errors" do 
          @assignment1.errors[:expected_return_date].should eq([" can't be blank for Temporary Assignment"]) 
        end
      end
    end
    context "on update" do 
      it "should_not receive temporarly_assignment_date" do 
        @assignment.should_not_receive(:temporarly_assignment_date)
        @assignment.save
      end
    end
  end
  
  describe "#add_commenter" do
    context "comments not present" do 
      before do 
        @assignment.stub(:comments).and_return([])
      end

      it "should receive comments once" do 
        @assignment.should_receive(:comments).once
        @assignment.add_commenter(@employee)
      end
    end

    context "comments present" do 
      before do 
        @commenter_id = @assignment.comments.last.commenter_id
      end

      it "should assign commenter_id" do 
        @assignment.add_commenter(@employee)
        @assignment.comments.last.commenter_id.should eq(@employee.id)
      end

      it "should change the value" do 
        @assignment.add_commenter(@employee)
        @assignment.comments.last.commenter_id.should_not eq(@commenter_id)
      end

      describe "should_receive methods" do 
        before do 
          @assignment.stub(:comments).and_return([@comment])
        end

        it "should_receive comments twice" do 
          @assignment.should_receive(:comments).twice
          @assignment.add_commenter(@employee)
        end
      end
    end
  end

  describe "attr_accessor assignment_type" do
    before do 
      @assignment.assignment_type = "Testing attr_accessor"
    end

    describe "reader method" do 
      it "should read the tags_field" do 
        @assignment.assignment_type.should eq("Testing attr_accessor")
      end
    end

    describe "writer method" do 
      it "should set tags_field value" do 
        @assignment.assignment_type = "test"
        @assignment.assignment_type.should eq("test")
        @assignment.assignment_type.should_not eq("Testing attr_accessor")
      end
    end
  end

  describe "alias_attribute retured" do 
    it "should alias of date_returned" do 
      @assignment.date_returned.should eq(@assignment.returned)
    end

    it "should_not raise error" do 
      expect{ @assignment.returned }.to_not raise_error
    end
  end
    
end
 