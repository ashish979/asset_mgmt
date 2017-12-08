require 'spec_helper'

describe HistoriesController do 
  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com") }
  let(:aem) { mock_model(Assignment, :save => true, :employee_id => 53, :asset_id => 1, :date_returned => DateTime.now, :remark => "assign") }
  let(:asset)  { mock_model(Asset, :save => true, "name"=>"Test Name", "status"=>"spare", "type"=>"Laptop", "currency_unit"=>"&#8377;", "cost"=>"100.0", "serial_number"=>"YUIYIU78sdf789IU", "vendor"=>"Test", "purchase_date"=>"29/09/2011", "resource_attributes"=>{"operating_system"=>"TEST OS", "has_bag"=>"false"}, "description"=>"Test Desc", "additional_info"=>"Test ADD Info") }
  
  before do 
    @admin = employee
    @assets = [asset]
    @employees = [employee]
    @aems = [aem]
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    controller.stub(:logout_if_disable).and_return(true)
    controller.stub(:verify_current_company)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
  end
  
  describe "INDEX" do 
    def send_request
      get :index, type: "employee", id: employee.id
    end

    before do 
      request.env["HTTP_REFERER"] = root_path
      Employee.stub(:where).with(id: employee.id, company_id: company.id).and_return([employee])
      Employee.stub(:with_deleted){ Employee.where(:id => employee.id, company_id: company.id).first } 
      employee.stub(:assignments).and_return(@aems)
      @aems.stub(:includes).with(:asset, :comments).and_return(@aems)
      @aems.stub(:order).with('asset_employee_mappings.date_returned desc').and_return(@aems)
    end

    context "params[:type] is employee" do 

      it "should_receive where" do 
        Employee.should_receive(:where).with(id: employee.id, company_id: company.id).and_return([employee])
        send_request
      end

      it "Employee should receive with_deleted" do 
        Employee.should_receive(:with_deleted).and_return(employee)
        send_request
      end

      it "should assigns instance variable record" do 
        send_request
        expect(assigns[:record]).to eq(employee)
      end
    end
    
    context "params[:type] is not employee" do 
      def send_request
        get :index, type: "asset", id: asset.id
      end

      before do 
        Asset.stub(:unscoped).and_return(@assets)
        @assets.stub(:where).with(id: asset.id.to_s, company_id: company.id).and_return(@assets)
        asset.stub(:assignments).and_return(@aems)
        @aems.stub(:includes).with(:employee, :comments).and_return(@aems)
        @aems.stub(:order).with('asset_employee_mappings.date_returned desc').and_return(@aems)
      end
      
      it "Asset should_receive where" do 
        Asset.should_receive(:unscoped).and_return(@assets)
        send_request
      end

      it "assets should_receive where" do 
        @assets.should_receive(:where).with(id: asset.id.to_s, company_id: company.id).and_return(@assets)
        send_request
      end

      it "should assigns instance variable recoed" do 
        send_request
        expect(assigns[:record]).to eq(asset)
      end
    end

    it "should render template index" do 
      send_request
      response.should render_template "index"
    end

    context "record found" do 
      it "employee should_receive assignments" do 
        employee.should_receive(:assignments).and_return(@aems)
        send_request
      end

      it "@aems should_receive includes" do 
        @aems.should_receive(:includes).with(:asset, :comments).and_return(@aems)
        send_request
      end

      it "should_receive order" do 
        @aems.should_receive(:order).with('asset_employee_mappings.date_returned desc').and_return(@aems)
        send_request
      end

      it "should not have flash alert" do 
        send_request
        flash[:alert].should_not eq("There are no history")
      end

      it "should_not redirect_to root_path" do 
        send_request
        response.should_not redirect_to root_path
      end

      it "should assigns histories" do 
        send_request
        expect(assigns[:histories]).to eq(@aems)
      end
    end

    context "record not found" do 
      before do 
        Employee.stub(:where).with(id: employee.id, company_id: company.id).and_return([])  
      end

      it "employee should_not_receive assignments" do 
        employee.should_not_receive(:assignments)
        send_request
      end

      it "@aems should_not_receive includes" do 
        @aems.should_not_receive(:includes)
        send_request
      end

      it "should_not_receive order" do 
        @aems.should_not_receive(:order)
        send_request
      end

      it "should have flash alert" do 
        send_request
        flash[:alert].should eq("There are no history")
      end

      it "should redirect_to root_path" do 
        send_request
        response.should redirect_to root_path
      end
    end
  end

end