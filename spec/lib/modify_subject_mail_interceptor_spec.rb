require 'spec_helper'

describe ModifySubjectMailInterceptor do
  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com") }
  let(:employee1) { mock_model(Employee, :save => true, :employee_id => 54, :name => "admin", :email => "admin@yahoooo.com") }
  let(:ticket_type)  { mock_model(TicketType, :save => true, "name"=>"upgrade", "company_id"=>company.id) }
  let(:ticket)  { mock_model(Ticket, :save => true,ticket_type_id: ticket_type.id, description: "Test Name", state: 1, employee_id: employee1.id) }
  let(:comment){mock_model(Comment, :save => true, resource_id: ticket.id, resource_type: 'Ticket', body: "Test COmment", commenter_id: employee.id)}
  let(:asset){mock_model(Asset)}
  let(:asset_type){mock_model(AssetType)}
  before(:each) do 
    @employees = [employee1]
    ticket.stub(:company).and_return(company)
    company.stub(:admins).and_return(@employees)
    @employees.stub(:where).and_return(@employees)
    @employees.stub(:not).and_return(@employees)
    @employees.stub(:pluck).with(:email).and_return([employee1.email])
    employee.stub(:company).and_return(company)
    employee1.stub(:company).and_return(company)
    company.stub(:permalink).and_return("Test")
    ticket.stub(:employee_name).and_return(employee.name)
    ticket.stub(:employee_email).and_return(employee.email)
    ticket.stub(:ticket_type_name).and_return(ticket_type.name)
    ticket.stub(:employee).and_return(employee)
    ticket.stub(:company_name).and_return("Vinsol")
    ticket.stub(:asset).and_return(asset)
    asset.stub(:name).and_return("name")
    asset.stub(:asset_type).and_return(asset_type)

    @message = TicketNotifier.ticket_creation_notification(ticket)
    @subject = @message.subject.dup
  end

  context "env not production" do 

    it "should modify subject" do 
      ModifySubjectMailInterceptor.delivering_email(@message)
      expect(@message.subject).to eq(@subject.prepend("[#{Rails.env}]"))
    end

    it "subject should include env" do 
      ModifySubjectMailInterceptor.delivering_email(@message)
      expect(@message.subject).to include("[#{Rails.env}]")
    end

  end

  context "env production" do 
    before do 
      Rails.env.stub(:production?).and_return(true)
    end
 
    it "should not modify subject" do 
      ModifySubjectMailInterceptor.delivering_email(@message)
      expect(@message.subject).to_not eq(@subject.prepend("[#{Rails.env}]"))
    end

    it "subject should not include env" do 
      ModifySubjectMailInterceptor.delivering_email(@message)
      expect(@message.subject).to_not include("[#{Rails.env}]")
    end
   
  end

end