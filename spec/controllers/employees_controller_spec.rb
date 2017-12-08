require 'spec_helper'
include ControllerHelper

describe EmployeesController do

  shared_examples_for 'call before_action :find_employee' do
    describe "should_receive methods" do 
      before do 
        company.stub(:employees).and_return(@employees)
        @employees.stub(:where).with(id: employee2.id.to_s).and_return([employee2])
      end

      it "controller should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company should_receive employees" do 
        company.should_receive(:employees).and_return(@employees)
      end

      it "employees should_receive where" do 
        @employees.should_receive(:where).with(id: employee2.id.to_s).and_return([employee2])
      end

      after do 
        send_request
      end

      it "should assigns instance variable" do 
        send_request
        expect(assigns[:employee]).to eq(employee2)
      end
    end

    context "employees not present" do 
      before do 
        company.stub(:employees).and_return(@employees)
        @employees.stub(:where).with(id: employee2.id.to_s).and_return([])
      end

      it "should redirect_to root_path" do 
        send_request
        response.should redirect_to root_path
      end

      it "should have flash notice" do 
        send_request
        flash[:alert].should eq("Could not find employee")
      end
    end

    context "employees present" do 

      it "should not redirect_to root_path" do 
        send_request
        response.should_not redirect_to root_path
      end

      it "should not have flash notice" do 
        send_request
        flash[:alert].should_not eq("Could not find employee")
      end
    end
  end

  shared_examples_for 'call before_action :find_unscoped_employee' do

    describe "should_receive methods" do 

      it "should_receive unscoped" do 
        Employee.should_receive(:unscoped).and_return(@employees)
      end

      it "@employees should receive where" do 
        @employees.should_receive(:where).with(id: employee2.id.to_s, company_id: company.try(:id)).and_return(@employees)
      end

      it "@employees should receive includes" do 
        @employees.should_receive(:includes).with(active_assignments: {asset: :asset_type}).and_return(@employees)
      end
     
      after do 
        send_request
      end
    end

    it "should assigns instance variable employees" do 
      send_request
      expect(assigns[:employee]).to eq(employee)
    end

    context "employee not found" do 
      before do 
        @employees.should_receive(:where).with(id: employee2.id.to_s, company_id: company.try(:id)).and_return(@employees)
        @employees.stub(:includes).with(active_assignments: {asset: :asset_type}).and_return([])
      end

      it "should have flash alert" do 
        send_request
        flash[:alert].should eq("Employee not found for specified id")
      end

      it "should redirect_to root" do 
        send_request
        response.should redirect_to root_path
      end
    end

    context "employee found" do 
      it "should not have flash alert" do 
        send_request
        flash[:alert].should_not eq("Employee not found for specified id")
      end

      it "should not redirect_to root" do 
        send_request
        response.should_not redirect_to root_path
      end
    end
  end

  let(:company) { mock_model(Company, :save => true, :id => 1) }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com") }
  let(:employee2) { mock_model(Employee, :save => true, :employee_id => 54, :name => "Test", :email => "test@yahoooo.com") }
  let(:aem) { mock_model(Assignment, :save => true, :employee_id => 4, :asset_id => 1, :date_returned => DateTime.now, :remark => "assign") }
  
  before do
    @admin = employee
    @aems = [aem]
    @employees = [employee, employee2]
    @valid_attributes = {"name" => "Ishank Gupta", "employee_id" => "53", "email" => "ishank_18@yahoooo.com"}  
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    company.stub(:id).and_return(company.id)
    controller.stub(:logout_if_disable).and_return(true)
    controller.stub(:verify_current_company)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
  end
  
  
  describe "INDEX" do
    def send_request type = nil
      get :index , :type => type, :page => "1"
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:index, Employee)
      Employee.stub(:where).with(company_id: company.id).and_return(@employees)
      Employee.stub(:with_deleted){ Employee.where(company_id: company.try(:id)) }
      @employees.stub(:includes).with(:assignments, :roles).and_return(@employees)
      @employees.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@employees)
      @employees.stub(:order).with('name asc').and_return(@employees)
    end

    context "params[:type] is not present" do
      it "should_receive with_deleted" do 
        Employee.should_receive(:with_deleted).and_return(@employees)
        send_request  
      end

      it "should assign instance variable employees" do 
        send_request
        expect(assigns[:employees]).to eq(@employees)
      end
    end

    context "params[:type] is 'enabled'" do 
      before do 
        Employee.stub(:enabled).with(company).and_return(@employees)
      end

      it "should_receive enabled" do 
        Employee.should_receive(:enabled).with(company).and_return(@employees)
        send_request("enabled")
      end

      it "should assign instance variable employees" do 
        send_request("enabled")
        expect(assigns[:employees]).to eq(@employees)
      end
    end

    context "params[:type] is disabled" do 
      before do 
        Employee.stub(:disabled).with(company).and_return(@employees)
      end

      it "should_receive enabled" do 
        Employee.should_receive(:disabled).with(company).and_return(@employees)
        send_request("disabled")
      end

      it "should assign instance variable employees" do 
        send_request("disabled")
        expect(assigns[:employees]).to eq(@employees)
      end
    end

    context "params[:type] is 'test'" do 
      it "should raise an exception" do 
        expect{ send_request('test') }.to raise_exception
      end
    end

    describe "should receive methods in all conditions" do 

      it "receive includes" do
        @employees.should_receive(:includes).and_return(@employees)
      end

      it "receive includes" do
        @employees.should_receive(:order).with("name asc").and_return(@employees)
      end

      it "receive paginate" do
        @employees.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@employees)
      end

      after do 
        send_request
      end
    end

    it "should render index" do 
      send_request
      response.should render_template "index"
    end

    it "should assign instance variable employees" do 
      send_request
      expect(assigns[:employees]).to eq(@employees)
    end
  end

  describe "SHOW" do 
    def send_request 
      get :show, :id => employee2.id.to_s
    end

    it_should 'call before_action :find_unscoped_employee'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:show, employee)
      Employee.stub(:unscoped).and_return(@employees)
      @employees.stub(:where).with(id: employee2.id.to_s, company_id: company.try(:id)).and_return(@employees)
      @employees.stub(:includes).with(active_assignments: {asset: :asset_type}).and_return(@employees)
      employee.stub(:returned_assignments).and_return(@aems)
      @aems.stub(:includes).with(asset: :asset_type).and_return(@aems)
      @aems.stub(:order).with('asset_employee_mappings.date_returned desc').and_return(@aems)
    end
    
    describe "should_receive methods" do 
      
      it "should_receive returned_assignments" do
        employee.should_receive(:returned_assignments).and_return(@aems)
      end

      it "should_receive includes" do 
        @aems.should_receive(:includes).with(asset: :asset_type).and_return(@aems)
      end

      it "should_receive order" do 
        @aems.should_receive(:order).with('asset_employee_mappings.date_returned desc').and_return(@aems) 
      end
     
      after do 
        send_request
      end
    end

    it "should render template show" do 
      send_request
      response.should render_template "show"
    end

    it "should assign instance variable history" do 
      send_request
      expect(assigns[:history]).to eq(@aems)
    end
  end

  describe "NEW" do 
    def send_request
      get :new
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:new, Employee)
    end

    it "assigns a new employee as employee" do
      send_request
      assigns(:employee).should be_a_new(Employee)
    end

    it "should render_template new" do 
      send_request
      response.should render_template("new")
    end
    
    describe "should_receive methods" do 
      before do 
        Employee.stub(:new).and_return(employee)
      end

      it "should_receive new" do 
        Employee.should_receive(:new).and_return(employee)
        send_request
      end
    end
  end
  
  describe "EDIT" do 
    def send_request
      get :edit, id: employee2.id
    end
    
    it_should 'call before_action :find_employee'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:edit, employee2)
      company.stub(:employees).and_return(@employees)
      @employees.stub(:where).with(id: employee2.id.to_s).and_return([employee2])
    end

    it "should render_template edit" do 
      send_request
      response.should render_template("edit")
    end
  end

  describe "CREATE" do
    def send_request
      post :create, :employee => @valid_attributes
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:create, Employee)
      company.stub(:employees).and_return(@employees)
      @employees.stub(:new).with(@valid_attributes).and_return(employee2)
      employee2.stub(:skip_confirmation_notification!).and_return(true)
    end
    
    context "with valid attributes" do 
      before do 
        post :create, :employee => @valid_attributes
      end
      
      it "assigns a newly created employee as employee" do
        assigns(:employee).should be_a(Employee)
      end

      it "should be persisted" do 
        assigns(:employee).should be_persisted
      end

      it "should redirect_to index" do 
        response.should redirect_to(employees_path)
      end

      it "should have flash" do 
        flash[:notice].should eq("Employee #{employee2.name} has been created successfully")
      end
    end

    context "record not created" do 
      before do 
        employee2.stub(:save).and_return(false)
      end 

      it "should render template new" do 
        send_request
        response.should render_template 'new'
      end
    end

    describe "should_receive methods" do 

      before do 
        controller.stub(:params_employee).and_return(@valid_attributes)
        company.stub(:employees).and_return(@employees)
        @employees.stub(:new).with(@valid_attributes).and_return(employee2)
        employee2.stub(:skip_confirmation_notification!).and_return(true)
        employee2.stub(:company_id=).and_return(company.id)
        employee2.stub(:save).and_return(true)
      end
      
      it "should_receive params_employee" do 
        controller.should_receive(:params_employee).and_return(@valid_attributes)
      end

      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive employees" do 
        company.should_receive(:employees).and_return(@employees)
      end

      it "should_receive new" do 
        @employees.should_receive(:new).with(@valid_attributes).and_return(employee2)
      end

      it "should_receive save" do 
        employee2.should_receive(:save).and_return(true)
      end

      after do 
        send_request
      end
    end
  end

  describe "UPDATE" do 
    def send_request
      put :update, id: employee2.id, employee: @valid_attributes
    end

    it_should 'call before_action :find_employee'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:update, employee2)
      company.stub(:employees).and_return(@employees)
      @employees.stub(:where).with(id: employee2.id.to_s).and_return([employee2])
      employee2.stub(:update_attributes).with(@valid_attributes).and_return(true)
      employee2.stub(:manage_admin_role!).and_return(true)
      employee2.stub(:has_role?)
    end

    context "html request" do 
      it "should_receive params_employee" do 
        controller.should_receive(:params_employee).and_return(@valid_attributes)
        send_request
      end

      it "should_receive update_attributes" do 
        employee2.should_receive(:update_attributes).with(@valid_attributes).and_return(true)
        send_request
      end

      it "should_not_receive toggle" do 
        employee2.should_not_receive(:toggle!)
        send_request
      end

      it "should_not_receive delay" do 
        employee2.should_not_receive(:delay)
        send_request
      end

      it "should_not_receive send_confirmation_instructions" do 
        employee2.should_not_receive(:send_confirmation_instructions)
        send_request
      end

      it "should not have flash" do 
        send_request
        flash.now[:notice].should_not eq("#{employee2.name} #{employee2.has_role?(:admin) ? 'marked as admin' : 'is no longer admin'}")
      end


      context "updated" do 
        it "should redirect_to show" do 
          send_request
          response.should redirect_to(employee2)
        end

        it "should have flash notice" do 
          send_request
          flash[:notice].should eq("Employee #{employee2.name} has been updated successfully")
        end
      end

      context "Update fail" do 
        before do 
          employee2.stub(:update_attributes).with(@valid_attributes).and_return(false)
          send_request
        end

        it "should render_template edit" do 
          response.should render_template "edit"
        end

        it "should not have flash notice" do 
          send_request
          flash[:notice].should_not eq("Employee #{employee2.name} has been updated successfully")
        end
      end
    end

    context "xhr request" do 
      def send_request
        xhr :put, :update, id: employee2.id 
      end

      before do 
        employee2.stub(:toggle!).with(:is_admin).and_return(true)
        employee2.stub(:update_attributes).with(confirmed_at: nil, encrypted_password: "").and_return(true)
        employee2.stub(:has_role?).with(:admin).and_return(true)
      end

      it "should render_template update" do 
        send_request
        response.should render_template "update"
      end

      context "employee is current_employee" do 
        before do 
          controller.stub(:current_employee).and_return(employee2)
        end

        it "should have flash message" do 
          send_request
          flash.now[:notice].should eq("You can not disable yourself")
        end
        
        it "should_not_receive manage_admin_role!" do 
          employee2.should_not_receive(:manage_admin_role!)
          send_request
        end

        it "should have no success flash" do 
          send_request
          flash.now[:notice].should_not eq("#{employee2.name} #{employee2.has_role?(:admin) ? 'marked as admin' : 'is no longer admin'}")
        end
      end

      context "employee is not current_employee" do 

        it "should_receive manage_admin_role!" do 
          employee2.should_receive(:manage_admin_role!).and_return(true)
          send_request
        end

        it "should have flash" do 
          send_request
          flash.now[:notice].should eq("#{employee2.name} #{employee2.has_role?(:admin) ? 'marked as admin' : 'is no longer admin'}")
        end
      end
    end
  end

  describe "ENABLE" do 

    def send_request
      put :enable, id: employee2.id
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:enable, Employee)
      company.stub(:employees).and_return(@employees)
      @employees.stub(:where).with(id: employee2.id).and_return([employee2])
      @employees.stub(:with_deleted){ company.employees.where(:id => employee2.id).first }
      employee2.stub(:soft_undelete!).and_return(true)
      request.env["HTTP_REFERER"] = employees_path
    end
    
    describe "should_receive methods" do 

      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company receive employees" do 
        company.should_receive(:employees).and_return(@employees)
      end

      it "@employees receive with_deleted" do 
        @employees.should_receive(:with_deleted).and_return(employee2)
      end

      it "should_receive soft_undelete" do 
        employee2.should_receive(:soft_undelete!).and_return(true)
      end

      after do 
        send_request
      end
    end

    context "enabled successfully" do 
      it "should redirect_to back" do
        send_request
        response.should redirect_to employees_path
      end

      it "should have a flash notice" do 
        send_request
        flash[:notice].should eq("Employee Test has been enabled successfully")
      end
    end

    context "not enabled" do 
      before do 
        employee2.stub(:soft_undelete!).and_return(false)
        send_request
      end

      it "should redirect_to disabled_employee_path" do 
        response.should redirect_to employees_path
      end

      it "should have a flash alert" do
        send_request
        flash[:alert].should eq("Employee #{employee2.name} has not been enabled successfully") 
      end
    end
  end

  describe "DISABLE" do 
    def send_request
      put :disable, id: employee2.id
    end

    it_should 'call before_action :find_employee'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:disable, employee2)
      company.stub(:employees).and_return(@employees)
      @employees.stub(:where).with(id: employee2.id.to_s).and_return([employee2])
      employee2.stub(:can_be_disabled?).and_return(true)
      employee2.stub(:soft_delete!).and_return(true)
      request.env["HTTP_REFERER"] = employees_path
    end
    
    it "should receive can_be_disabled?" do
      employee2.should_receive(:can_be_disabled?).and_return(true)
      send_request
    end

    context "employee can not be disabled" do 
      before do 
        employee2.stub(:can_be_disabled?).and_return(false)
      end

      it "should redirect_to back" do 
        send_request 
        response.should redirect_to employees_path
      end

      it "should have a flash alert" do 
        send_request
        flash[:alert].should eq("First remove all assigned asset from Test")
      end
    end

    context "employee can be disabled" do 
      before do 
        employee2.stub(:can_be_disabled?).and_return(true)
      end
      
      it "should_receive soft_delete" do 
        employee2.should_receive(:soft_delete!).and_return(true)
        send_request
      end

      it "should redirect_to employees_path" do 
        send_request
        response.should redirect_to employees_path
      end

      it "should have a flash notice" do 
        send_request
        flash[:notice].should eq( "Employee Test has been disabled successfully")
      end
    end
  end

  describe "get_autocomplete_items" do 
    before do 
      should_authorize(:get_autocomplete_items, Employee)
      @parameters = {:model=>Employee, :options=>{:full=>true, :limit=>1000}, :term=>"test", :method=>:name}
      @result = Employee.select(:id, :name).where(name: "test")
    end

    def send_request
      xhr :get, :autocomplete_employee_name, term: 'test'
    end

    context "employees from current_company" do 
      context "search term is name"  do 
        it "should return employees having search term in name" do 
          controller.get_autocomplete_items(@parameters).first.should eq(@result.first)
        end
      end
    end

    context "employees not from current_company" do 
      before do 
        controller.stub(:current_company).and_return(company)
        company.stub(:id).and_return("100")
      end
      context "search term is name"  do 
        it "should return blank result" do 
          controller.get_autocomplete_items(@parameters).should eq([])
        end
      end
    end
  end

  describe "edit_password" do 
    def send_request
      get :edit_password
    end

    it_should 'should_receive skip_authorize_resource'
   
    it "should assign employee" do 
      send_request
      expect(assigns[:employee]).to eq(employee)
    end
  end

  describe "update_password" do 
    def send_request
      put :update_password, password: "vinsol123", password_confirmation: "vinsol123"
    end

    it_should 'should_receive skip_authorize_resource'

    before do 
      controller.stub(:params_employee).and_return(@valid_attributes)
      employee.stub(:update_with_password).with(@valid_attributes).and_return(true)
    end    

    it "should assign employee" do 
      send_request
      expect(assigns[:employee]).to eq(employee)
    end
     
    it "should_receive params_employee" do 
      controller.should_receive(:params_employee).and_return(@valid_attributes)
      send_request
    end

    it "should_receive update_without_password" do 
      employee.should_receive(:update_with_password).with(@valid_attributes).and_return(true)
      send_request
    end

    context "updated successfully" do 
      it "should redirect_to root_path" do 
        send_request
        response.should redirect_to root_path
      end
    end

    context "not updated" do 
      before do 
        employee.stub(:update_with_password).with(@valid_attributes).and_return(false)
      end
      it "should render_template reset" do 
        send_request
        response.should render_template "edit_password"
      end
    end
  end

  describe "#assignment_report" do 
    def send_request
      get :assignment_report, page: 1
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:assignment_report, Employee)
      Employee.stub(:enabled).with(company).and_return(@employees)
      @employees.stub(:includes).with(:active_assignments => :asset).and_return(@employees)
      @employees.stub(:order).with("name asc").and_return(@employees)
      @employees.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@employees)      
    end
    
    describe "should_receive methods" do 

      it "should_receive enabled" do 
        Employee.should_receive(:enabled).with(company).and_return(@employees)  
      end
      
      it "should_receive includes" do 
        @employees.should_receive(:includes).with(:active_assignments => :asset).and_return(@employees)  
      end

      it "should_receive order " do 
        @employees.stub(:order).with("name asc").and_return(@employees)
      end

      after do 
        send_request
      end
    end

    it "should assign instance variable employees" do 
      send_request
      expect(assigns[:employees]).to eq(@employees)
    end

    it "should render_template assignment_report" do 
      send_request
      response.should render_template "assignment_report"
    end

    context "html request" do 
      it "should_receive paginate" do 
        @employees.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@employees)
        send_request
      end
    end

    context "xhr request" do 
      def send_request
        xhr :get, :assignment_report, page: 1
      end
    
      it "should_not_receive paginate" do 
        @employees.should_not_receive(:paginate)
        send_request
      end
    end
  end

  describe "autocomplete" do 
    it "should define autocomplete method" do 
      EmployeesController.method_defined?(:autocomplete_employee_name).should be_true
    end
  end

  #Rails 4 strong parameter
  describe "params_employee" do 
    def send_request
      put :update, id: employee2.id, employee: {"name" => "Ishank Gupta"}  
    end

    before do 
      should_authorize(:update, employee2)
      company.stub(:employees).and_return(@employees)
      @employees.stub(:where).with(id: employee2.id.to_s).and_return([employee2])
      employee2.stub(:update_attributes).with("name"=>"Ishank Gupta").and_return(true)
      employee2.stub(:manage_admin_role!).and_return(true)
      employee2.stub(:has_role?)
    end

    context "with permitted parameter" do 

      it "should_receive permit" do 
        employee2.should_receive(:update_attributes).with({"name" => "Ishank Gupta"})
      end

      after do
        send_request
      end
    end

    context "with unpermitted parameter" do 
      it "should_receive permit" do 
        employee2.should_receive(:update_attributes).with({"name" => "Ishank Gupta"})
      end
      
      it "should_not_receive permit with unpermitted data" do 
        employee2.should_not_receive(:update_attributes).with({"name" => "Ishank Gupta", created_at: Time.now})
      end

      after do
        put :update, id: employee2.id, employee: {"name" => "Ishank Gupta", created_at: Time.now}  
      end
    end
  end

end  
