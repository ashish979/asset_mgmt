require 'spec_helper'

describe TicketType do 

  it_should 'use restrictive destroy'
  
  before(:each) do 
    @role1 = Role.create(name: "employee")
    @role2 = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: 'test@vinsol.com')
    @employee = Employee.create(email: "ashutosh.tiwari@vinsol.com", name: "Ashutosh", employee_id: 2, company_id: @company.id)
    @role = Role.new(name: Employee::ROLES[1])
    @ticket_type = TicketType.create(name: "New Hardware", company_id: @company.id)
    @ticket_type1 = TicketType.create(name: "Upgrade Hardware", company_id: @company.id)
    Ticket.any_instance.stub(:asset_assigned?).and_return(true)
    @ticket = Ticket.create(ticket_type_id: @ticket_type.id, description: "Test", employee_id: @employee.id, state: Ticket::STATE[:open], company_id: @company.id)
  end

  describe 'validation' do 
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:company_id).case_insensitive }
  end
  
  describe "association" do 
    it { should belong_to(:company) }
    it { should have_many(:tickets) }
  end

  describe "#new_hardware?" do 
    context "new_hardware" do 
      it "should return true" do 
        @ticket.new_hardware?.should eq(true)
      end
    end

    context "not new_hardware" do 
      before do 
        @ticket.update_column(:ticket_type_id, @ticket_type1.id)
      end

      it "should return false" do 
        @ticket.new_hardware?.should eq(false)
      end
    end
  end

end