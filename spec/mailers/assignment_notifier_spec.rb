require 'spec_helper'

describe AssignmentNotifier do
  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com") }
  let(:employee1) { mock_model(Employee, :save => true, :employee_id => 54, :name => "admin", :email => "admin@yahoooo.com") }
  let(:asset_type)  { mock_model(AssetType, :save => true, "name"=>"laptop", "company_id"=>company.id) }
  let(:asset)  { mock_model(Asset, :save => true,"asset_type_id"=>asset_type.id, "name"=>"Test Name", "status"=>"spare", "brand"=> "HP", "type"=>"Laptop", "currency_unit"=>"&#8377;", "cost"=>"100.0", "serial_number"=>"YUIYIU78sdf789IU", "vendor"=>"Test", "purchase_date"=>"29/09/2011", "description"=>"Test Desc", "additional_info"=>"Test ADD Info") }

  describe 'assignment_notification' do
    def call_assignment_notification
      AssignmentNotifier.assignment_notification(employee, asset, true, employee1)
    end
    
    before do 
      @employees = [employee1]
      employee.stub(:company).and_return(company)
      company.stub(:admins).and_return(@employees)
      @employees.stub(:pluck).with(:email).and_return(["admin@yahoooo.com"])
      asset.stub(:display_name).and_return(asset.name)
      company.stub(:name).and_return('Vinsol Test')
      employee1.stub(:company).and_return(company)
      employee1.stub(:company_name).and_return(company.name)
      employee.stub(:company_name).and_return(company.name)
      company.stub(:permalink).and_return("test")
    end
  
    it { call_assignment_notification.to.should eq([employee.email]) }
    it { call_assignment_notification.from.should eq([employee1.email]) }
    it { call_assignment_notification.cc.should eq([employee1.email]) }
    it { call_assignment_notification.body.encoded.should include(asset.name) }
    it { call_assignment_notification.body.encoded.should include(employee.name) }
    it { call_assignment_notification.body.encoded.should include(asset.serial_number) }
    
    context "assigned" do 
      it { call_assignment_notification.subject.should eq("[#{company.name}] Test Name is assigned to you.") }
    end

    context "returned" do 
      it { AssignmentNotifier.assignment_notification(employee, asset, false, employee1).subject.should eq("[#{company.name}] Thanks for returning Test Name.") }
    end
  end
end
