require 'spec_helper'

describe TicketNotifier do
  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com") }
  let(:employee1) { mock_model(Employee, :save => true, :employee_id => 54, :name => "admin", :email => "admin@yahoooo.com") }
  let(:ticket_type)  { mock_model(TicketType, :save => true, "name"=>"upgrade", "company_id"=>company.id) }
  let(:ticket)  { mock_model(Ticket, :save => true,ticket_type_id: ticket_type.id, description: "Test Name", state: 1, employee_id: employee1.id) }
  let(:comment){mock_model(Comment, :save => true, resource_id: ticket.id, resource_type: 'Ticket', body: "Test COmment", commenter_id: employee.id)}
  let(:asset){mock_model(Asset)}
  let(:asset_type){mock_model(AssetType)}
  before do 
    @employees = [employee1]
    ticket.stub(:company).and_return(company)
    company.stub(:admins).and_return(@employees)
    @employees.stub(:where).and_return(@employees)
    @employees.stub(:not).and_return(@employees)
    asset.stub(:asset_type).and_return(asset_type)

    @employees.stub(:pluck).with(:email).and_return([employee1.email])
    employee.stub(:company).and_return(company)
    employee1.stub(:company).and_return(company)
    company.stub(:permalink).and_return("test")
    ticket.stub(:employee_name).and_return(employee.name)
    ticket.stub(:employee_email).and_return(employee.email)
    ticket.stub(:company_name).and_return(company.name)
    ticket.stub(:ticket_type_name).and_return(ticket_type.name)
    ticket.stub(:employee).and_return(employee)
    employee.stub(:company_name).and_return(company.name)
    employee1.stub(:company_name).and_return(company.name)
    ticket.stub(:asset).and_return(asset)
    ticket.stub(:title).and_return(ticket.id)
    asset.stub(:name).and_return("name")
  end

  describe 'ticket_creation_notification' do
    def call_ticket_creation_notification
      TicketNotifier.ticket_creation_notification(ticket)
    end
      
    it { call_ticket_creation_notification.to.should eq([employee.email]) }
    it { call_ticket_creation_notification.from.should eq(["hr@vinsol.com"]) }
    it { call_ticket_creation_notification.cc.should eq([employee1.email]) }
    it { call_ticket_creation_notification.subject.should eq("[#{company.name}] New ticket notification") }
    it { call_ticket_creation_notification.body.encoded.should include(ticket.description) }
    it { call_ticket_creation_notification.body.encoded.should include(ticket.ticket_type_name) }
    it { call_ticket_creation_notification.body.encoded.should include(ticket.employee_name) }
  end

  describe 'ticket_creation_notification' do
    before do 
      comment.stub(:resource).and_return(ticket)
    end

    def call_send_comment_notification
      TicketNotifier.send_comment_notification(comment, employee)
    end

    it { call_send_comment_notification.from.should eq([employee.email]) }
    it { call_send_comment_notification.subject.should eq("[#{company.name}] #{employee.name} has commented on ticket ##{comment.resource.id}") }
    it { call_send_comment_notification.body.encoded.should include(comment.body) }
    it { call_send_comment_notification.body.encoded.should include(employee.name) }

    context "commenter is admin" do
      before do 
        ticket.stub(:employee_id).and_return(employee1.id)
      end 
      it { TicketNotifier.send_comment_notification(comment, employee1).to.should eq([employee1.email]) }  
    end

    context "commenter is employee" do
      before do 
        ticket.stub(:employee_id).and_return(employee1.id)
      end  
      it { call_send_comment_notification.to.should eq([employee.email]) }  
    end
  end
end
