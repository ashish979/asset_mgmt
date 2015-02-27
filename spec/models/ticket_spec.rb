require 'spec_helper'

describe Ticket do 

  it_should 'use restrictive destroy'
  it_should 'use commentable module'
  it_should 'send ticket creation notification'

  before(:each) do
    @role1 = Role.create(name: "employee") 
    @role = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: 'test@vinsol.com')
    @company1 = Company.create(name: "Test", email: 'test@test.com')
    @employee = Employee.create(email: "ashutosh.tiwari@vinsol.com", name: "Ashutosh", employee_id: 2, company_id: @company.id)
    @role = Role.new(name: Employee::ROLES[1])
    @asset_type = AssetType.create(name: 'laptop')
    @asset = Asset.create!(asset_type_id: @asset_type.id,:status => "spare", :name => "Test Name", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :brand => "hp", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @asset1 = Asset.create!(asset_type_id: @asset_type.id,:status => "spare", :name => "Test", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUXIYIU78sdf789IU", :brand => "hp", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company1.id)
    @ticket_type = TicketType.create(name: "New Hardware", company_id: @company.id)
    @ticket_type1 = TicketType.create(name: "Upgrade Hardware", company_id: @company.id)
    @assignment = Assignment.create!(asset_id: @asset.id, employee_id: @employee.id, assignment_type: "Temporary", date_issued: DateTime.now - 6)
    
    @ticket = Ticket.create(ticket_type_id: @ticket_type.id, description: "Test", employee_id: @employee.id, state: Ticket::STATE[:open], company_id: @company.id)
    @tickets = [@ticket]
  end

  describe "STATE constants" do 
    it "should equal to given hash" do 
      Ticket::STATE.should eq({ open: 1, closed: 2 })
    end
  end

  describe 'validation' do 
    before do 
      Ticket.any_instance.stub(:validate_asset).and_return(true)
    end

    it { should validate_presence_of(:ticket_type) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:employee) }
  end
  
  describe "association" do 
    it { should belong_to(:employee) }
    it { should belong_to(:company) }
    it { should belong_to(:ticket_type) }
    it { should belong_to(:asset) }
  end

  describe "delegation" do 
    it { should delegate(:name).to(:employee).with_prefix }
    it { should delegate(:email).to(:employee).with_prefix }
    it { should delegate(:name).to(:ticket_type).with_prefix }
    it { should delegate(:name).to(:company).with_prefix }
  end

  describe "attr_readonly description" do 
    it { should have_readonly_attribute(:description) }
  end
  
  describe "#open?" do 
    it "should return true if state is Ticket::STATE[:open]" do 
      @ticket.open?.should eq(true)
    end

    it "should return false if not open" do 
      @ticket.update_column(:state, Ticket::STATE[:closed])
      @ticket.reload.open?.should eq(false)
    end
  end

  describe "#change_state!" do 
    context "state open" do 
      before do 
        @old = @ticket.state
        @ticket.change_state!
      end

      it "should change it to closed" do 
        @ticket.state.should eq(Ticket::STATE[:closed])
      end

      it "should change value" do 
        @old.should_not eq(@ticket.state)
      end
    end

    context "state closed" do 
      before do 
        @ticket.update_column(:state, Ticket::STATE[:closed])
        @old = @ticket.state
        @ticket.change_state!
      end

      it "should change it to open" do 
        @ticket.state.should eq(Ticket::STATE[:open])
      end

      it "should change value" do 
        @old.should_not eq(@ticket.state)
      end
    end
  end

  describe "#new_hardware?" do 
    context "name is new hardware" do 
      before do 
        @ticket.ticket_type.stub(:name).and_return('New Hardware')
      end

      it "should return true" do 
        @ticket.new_hardware?.should eq(true)
      end
    end

    context "name is not new hardware" do 
      before do 
        @ticket.ticket_type.stub(:name).and_return('New')
      end
      it "should return false" do 
        @ticket.new_hardware?.should eq(false)
      end
    end
  end

  describe "#validate presence for asset" do
    context "new_hardware" do 
      before do 
        @ticket1 = Ticket.new(ticket_type_id: @ticket_type.id, description: "Test", employee_id: @employee.id, state: Ticket::STATE[:open], company_id: @company.id)     
      end

      it "should be valid" do 
        @ticket1.valid?.should be_true
      end

    end

    context"not new_hardware" do 
      before do 
        @ticket2 = Ticket.new(ticket_type_id: @ticket_type1.id, description: "Test", employee_id: @employee.id, state: Ticket::STATE[:open], company_id: @company.id)     
      end
      
      it "should not be valid if asset not present" do 
        @ticket2.valid?.should be_false
      end
      
      it "should be valid if asset present" do
        @ticket3 = Ticket.new(asset_id: @asset.id, ticket_type_id: @ticket_type1.id, description: "Test", employee_id: @employee.id, state: Ticket::STATE[:open], company_id: @company.id)     
        @ticket3.valid?.should be_true
      end
    end
  end

  describe "#title" do 
    it "should return title" do 
      @ticket.title.should eq("Ticket ##{@ticket.id}")
    end
  end

  describe "#new_state" do 
    context "ticket is open" do 
      before do 
        @ticket.stub(:open?).and_return(true)
        @ticket.stub(:update_column).with(:state, Ticket::STATE[:closed])
      end

      it "update_column should receive with STATE[:closed]" do 
        @ticket.should_receive(:update_column).with(:state, Ticket::STATE[:closed])
        @ticket.change_state!
      end
    end

    context "ticket is closed" do 
      before do 
        @ticket.stub(:open?).and_return(false)
        @ticket.stub(:update_column).with(:state, Ticket::STATE[:open])
      end

      it "update_column should receive with STATE[:open]" do 
        @ticket.should_receive(:update_column).with(:state, Ticket::STATE[:open])
        @ticket.change_state!
      end
    end
  end

  describe "#validate_asset" do 
    before do 
      @ticket1 = Ticket.new(ticket_type_id: @ticket_type1.id, description: "Test", employee_id: @employee.id, state: Ticket::STATE[:open], company_id: @company.id, asset_id: @asset.id)
    end

    context "company has asset" do 
      it "should not add error to base" do 
        @ticket1.valid?
        @ticket1.errors[:base].should_not eq(["Asset does not exists."])
      end
    end

    context "company has not asset" do 
      before do 
        @ticket4 = Ticket.new(ticket_type_id: @ticket_type1.id, description: "Test", employee_id: @employee.id, company_id: @company.id, asset_id: @asset1.id)
        @ticket4.valid?
      end

      it "should add error to base" do 
        @ticket4.errors[:base].should eq(["Asset does not exists."])
      end
    end

    context "role is admin" do
      before do 
        @employee.roles << Role.all[1]
      end 

      it "should_not have error" do 
        @ticket1.valid?
        @ticket1.errors[:base].should eq([])
      end
    end

    context "role is employee" do 
      before do 
        @employee.roles = []
        @employee.roles << @role1
      end

      context "asset not assigned to employee" do 
        before do 
          Assignment.delete_all
        end

        it "should have error" do 
          @ticket1.valid?
          @ticket1.errors[:base].should eq(["#{@asset.name} is currently not assigned to you."])
        end
      end

      context "asset assigned to employee" do
   
        it "should not have error" do 
          @ticket1.valid?
          @ticket1.errors[:base].should eq([])
        end
      end
    end
  end

  describe ".search" do 
    before do 
      @conditions = []
      @conditions = ["tickets.id in (?)", @ticket.id]
    end

    describe "should_receive methods" do 
      before do 
        Ticket.stub(:search_conditions).with("Id", "open", @ticket.id, @employee).and_return(@conditions)
        Ticket.stub(:where).with(@conditions).and_return(@tickets)
      end

      it "should_receive search_conditions" do 
        Ticket.should_receive(:search_conditions).with("Id", "open", @ticket.id, @employee).and_return(@conditions)
        Ticket.search("Id", "open", @ticket.id, @employee)
      end

      it "should_receive where" do 
        Ticket.should_receive(:where).with(@conditions).and_return(@tickets)
        Ticket.search("Id", "open", @ticket.id, @employee)
      end
    end
    
    context "category present" do 
      context "category is Id" do 
        it "return ticket without state" do 
          expect(Ticket.search("Id", nil, "#{@ticket.id}", @employee)).to eq(@tickets)
        end

        it "return ticket with state open" do 
          expect(Ticket.search("Id", "open", "#{@ticket.id}", @employee)).to eq(@tickets)
        end

        it "should not return ticket with closed state" do 
          expect(Ticket.search("Id", "closed", "#{@ticket.id}", @employee)).to_not eq(@tickets)
        end
      end

      context "category id employee" do 
        it "return ticket without state" do 
          expect(Ticket.search("Employee", nil, "#{@employee.name}", @employee)).to eq(@tickets)
        end

        it "return ticket with state open" do 
          expect(Ticket.search("Employee", "open", "#{@employee.name}", @employee)).to eq(@tickets)
        end

        it "should not return ticket with state closed" do 
          expect(Ticket.search("Employee", "closed", "#{@employee.name}", @employee)).to_not eq(@tickets)
        end

      end
    end

    context "category not present" do 
      it "return ticket for name without state" do 
        expect(Ticket.search("", nil, "#{@employee.name}", @employee)).to eq(@tickets)
      end      

      it "return ticket for name with state open" do 
        expect(Ticket.search("", "open", "#{@employee.name}", @employee)).to eq(@tickets)
      end

      it "should not return ticket for name with state closed" do 
        expect(Ticket.search("", "closed", "#{@employee.name}", @employee)).to_not eq(@tickets)
      end

      it "return ticket for id without state" do 
        expect(Ticket.search("", nil, "#{@ticket.id}", @employee)).to eq(@tickets)
      end

      it "return ticket for id with state open" do 
        expect(Ticket.search("", "open", "#{@ticket.id}", @employee)).to eq(@tickets)
      end

      it "should not return ticket for id with wrong state" do 
        expect(Ticket.search("", "closed", "#{@ticket.id}", @employee)).to_not eq(@tickets)
      end
    end
  end

  describe ".search_conditions" do 
    context "category present" do 
      context "category id" do 
        before do 
          Ticket.stub(:add_conditions).and_return("conditions")
        end

        it "should_receive add_conditions" do 
          Ticket.should_receive(:add_conditions).exactly(3).times.and_return("conditions")
          Ticket.search_conditions("Id", "open", @ticket.id, @employee)
        end
      end

      context "category asset" do 
        before do 
          Ticket.stub(:add_conditions).and_return("conditions")
        end
        it "should_receive add_conditions" do 
          Ticket.should_receive(:add_conditions).exactly(3).times.and_return("conditions")
          Ticket.search_conditions("Asset", "open", @asset.name, @employee)
        end
      end

      context "category employee" do 
        before do 
          Ticket.stub(:add_conditions).and_return("conditions")
        end
        it "should_receive add_conditions" do 
          Ticket.should_receive(:add_conditions).exactly(3).times.and_return("conditions")
          Ticket.search_conditions("Employee", "open", @employee.name, @employee)
        end
      end

      context "state present" do 
        it "should_receive add_conditions three times" do 
          Ticket.should_receive(:add_conditions).exactly(3).times.and_return("conditions")
          Ticket.search_conditions("Employee", "open", @employee.name, @employee)
        end
      end

      context "state not present" do 
        it "should_receive add_conditions two times" do 
          Ticket.should_receive(:add_conditions).exactly(2).times.and_return("conditions")
          Ticket.search_conditions("Employee", nil, @employee.name, @employee)
        end
      end
    end

    context "category not present" do 
      before do 
        Ticket.stub(:add_conditions).and_return("conditions")
      end
      it "should_receive add_conditions" do 
        Ticket.should_receive(:add_conditions).exactly(2).times.and_return("conditions")
        Ticket.search_conditions("", "open", @employee.name, @employee)
      end

      it "should_receive get_unscoped_asset_ids" do 
        Ticket.should_receive(:get_unscoped_asset_ids).with(@employee.name).and_return([@employee.id])
        Ticket.search_conditions("", "open", @employee.name, @employee)
      end

      it "should_receive get_unscoped_employee_ids" do 
        Ticket.should_receive(:get_unscoped_employee_ids).with(@employee.name).and_return([@employee.id])
        Ticket.search_conditions("", "open", @employee.name, @employee)
      end

      context "state present" do 
        it "should_receive add_conditions two times" do 
          Ticket.should_receive(:add_conditions).exactly(2).times.and_return("conditions")
          Ticket.search_conditions("", "open", @employee.name, @employee)
        end
      end

      context "state not present" do 
        it "should_receive add_conditions one time" do 
          Ticket.should_receive(:add_conditions).exactly(1).times.and_return("conditions")
          Ticket.search_conditions("", nil, @employee.name, @employee)
        end
      end
    end

  end

  describe ".get_unscoped_asset_ids" do   
    it "should return an array of ids" do 
      expect(Ticket.get_unscoped_asset_ids(@asset.name)).to eq([@asset.id])
    end
  end

  describe ".get_unscoped_employee_ids" do 
    it "should return an array of ids" do 
      expect(Ticket.get_unscoped_employee_ids(@employee.name)).to eq([@employee.id])
    end
  end

  describe ".add_conditions" do 
    before do 
      Ticket.search_conditions("", nil, @employee.name, @employee)
    end

    it "should return add value to @conditions" do
      Ticket.add_conditions(" AND conditions is", 1).should eq(["1 AND (tickets.asset_id in (?) OR tickets.employee_id in (?) OR tickets.id in (?)) AND tickets.company_id = ? AND conditions is", [], [@employee.id], "#{@employee.name}", @company.id, 1])
    end
  end

end