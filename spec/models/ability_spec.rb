require 'spec_helper'
require "cancan/matchers"

describe Ability do 
  
  before(:each) do 
    @role1 = Role.create(name: Employee::ROLES[0])
    @role2 = Role.create(name: Employee::ROLES[1])
    @role3 = Role.create(name: Employee::ROLES[2])
    @company = Company.create(name: "Vinsol", email: 'test@vinsol.com')
    @employee1 = Employee.create(email: "ashutosh.tiwari@vinsol.com", name: "Ashutosh", employee_id: 2, company_id: @company.id)
    @employee2 = Employee.create(email: "emp@vinsol.com", name: "Test", employee_id: 1, company_id: @company.id)
    @employee3 = Employee.create(email: "test2@vinsol.com", name: "test2", employee_id: 3, company_id: @company.id)
    @employee1.roles << @role1
    @employee2.roles << @role2
    @asset_type = AssetType.create(name: 'laptop')
    @asset1 = Asset.create!(asset_type_id: @asset_type.id, :status => "spare", :name => "Test", :brand => "HP", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIZYIU78sdf789IU", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @asset2 = Asset.create!(asset_type_id: @asset_type.id, :status => "spare", :name => "Test Name", :brand => "HP", :currency_unit => "&#8377;", :cost => "100.0", :serial_number => "YUIYIU78sdf789IU", :vendor => "Test", :purchase_date => DateTime.now - 6, :description => "Test Desc", :additional_info => "Test ADD Info", company_id: @company.id)
    @assignment1 = Assignment.create!(asset_id: @asset1.id, employee_id: @employee3.id, assignment_type: "Temporary", date_issued: DateTime.now - 6)
    @assignment2 = Assignment.create!(asset_id: @asset2.id, employee_id: @employee1.id, assignment_type: "Temporary", date_issued: DateTime.now - 6)

    @ticket_type = TicketType.create(name: "New Hardware", company_id: @company.id)
    @ticket1 = Ticket.create(ticket_type_id: @ticket_type.id, description: "Test", employee_id: @employee3.id, state: Ticket::STATE[:open], company_id: @company.id)
    @ticket2 = Ticket.create(ticket_type_id: @ticket_type.id, description: "Test Demo", employee_id: @employee1.id, state: Ticket::STATE[:open], company_id: @company.id)
  end


  describe 'Abilities' do 
    
    context "super admin" do 
      before do 
        @ability = Ability.new(@employee1)
      end

      it "should able to manage company" do 
        @ability.should be_able_to(:manage, Company)
      end

      it "should not be able to manage everything" do 
        @ability.should_not be_able_to(:manage, :all)
      end
    end

    context "employee admin" do
      before do 
        @ability = Ability.new(@employee2)
      end

      it "should able to manage everything" do 
        @ability.should be_able_to(:manage, :all)
      end

      it "should not able to manage company" do 
        @ability.should_not be_able_to(:manage, Company)
      end
    end

    context "other employee" do 
      before do 
        @ability = Ability.new(@employee3)
        @asset1.assign! 
        @asset2.assign! 
      end

      it "should not able to manage all" do 
        @ability.should_not be_able_to(:manage, :all)
      end

      context "employee tickets" do
        it "should able to manage Ticket" do 
          @ability.should be_able_to(:manage, @ticket1)
        end
      end

      context "not employee tickets" do 
        it "should not able to manage Ticket" do 
          @ability.should_not be_able_to(:manage, @ticket2)
        end
      end

      context "asset assigned" do 
        it "should be able to read asset" do 
          @ability.should be_able_to(:show, @asset1)
        end
      end

      context "asset not assigned" do 
        it "should not be able to read asset" do 
          @ability.should_not be_able_to(:show, @asset2)
        end
      end

    end
  end
end