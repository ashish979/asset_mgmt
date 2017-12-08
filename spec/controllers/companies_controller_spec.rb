require 'spec_helper'
include ControllerHelper

describe CompaniesController do

  shared_examples_for 'call before_action :find_company' do
    
    describe "should_receive methods" do 
      it "company should_receive where" do 
        Company.should_receive(:where).with(permalink: company.id.to_s).and_return([company])
      end

      after do 
        send_request
      end
    end

    context "company found" do 
      describe "assigns instance variable" do 
        it "should assign company" do 
          send_request
          expect(assigns[:company]).to eq(company)
        end

        it "should not have flash alert" do 
          send_request
          flash[:alert].should_not eq("Company not found for specified id")
        end
      end
    end

    context "company not found" do 
      before do 
        Company.stub(:where).with(permalink: company.id.to_s).and_return([])
      end
      describe "assigns instance variable" do 
        it "should assign company" do 
          send_request
          expect(assigns[:company]).to eq(nil)
        end

        it "should have flash alert" do 
          send_request
          flash[:alert].should eq("Company not found for specified id")
        end

        it "response should redirect_to index" do 
          send_request
          response.should redirect_to companies_path
        end
      end
    end
  end

  shared_examples_for 'call skip_before_filter :verify_current_company' do

    it "should_not_receive verify_current_company" do 
      controller.should_not_receive(:verify_current_company)
      send_request
    end
  end


  let(:company) { mock_model(Company, :save => true, :name => "Vinsol", :email => "hr@vinsol.com") }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com") }
  
  before do
    @admin = employee
    @valid_attributes = {name: "Abc Info", email: "hr@abcinfo.com"}
    @companies = [company]
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    controller.stub(:logout_if_disable).and_return(true)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
  end
  
  describe "INDEX" do 
    def send_request
      get :index, page: "1" 
    end

    it_should 'call skip_before_filter :verify_current_company'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:index, Company)
      Company.stub(:all).and_return(@companies)
      @companies.stub(:paginate).with(page: "1", per_page: 100).and_return(@companies)
    end

    context "should receive methods" do 
      it "Company should_receive all" do 
        Company.should_receive(:all).and_return(@companies)
      end

      it "@companies should_receive paginate" do 
        @companies.should_receive(:paginate).with(page: "1", per_page: 100).and_return(@companies)
      end

      after do 
        send_request
      end
    end

    it "should render template index" do 
      send_request
      response.should render_template "index"
    end

    it "should assign instance variable companies" do
      send_request
      expect(assigns[:companies]).to eq(@companies)
    end
  end

  describe "NEW" do 
    def send_request
      get :new
    end

    it_should 'call skip_before_filter :verify_current_company'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:new, Company)
    end

    it "assigns a new company as company" do
      send_request
      assigns(:company).should be_a_new(Company)
    end

    it "should render_template new" do 
      send_request
      response.should render_template("new")
    end

    it "should_receive new" do 
      Company.should_receive(:new).and_return(company)
      send_request
    end
  end

  describe "EDIT" do 
    def send_request
      get :edit, id: company.id.to_s
    end

    it_should 'call before_action :find_company'
    it_should 'call skip_before_filter :verify_current_company'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:edit, company)
      Company.stub(:where).with(permalink: company.id.to_s).and_return([company])
    end

    it "should render_template edit" do 
      send_request
      response.should render_template("edit")
    end
  end

  describe "CREATE" do 
    def send_request
      post :create, company: @valid_attributes
    end
    
    it_should 'call skip_before_filter :verify_current_company'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:create, Company)
      Company.any_instance.stub(:create_default_admin).and_return(true)
      Employee.any_instance.stub(:assign_default_role).and_return(true)
    end

    context "with valid attributes" do 
      before do 
        post :create, company: @valid_attributes
      end
      
      it "assigns a newly created company as company" do
        assigns(:company).should be_a(Company)
      end

      it "should be persisted" do 
        assigns(:company).should be_persisted
      end

      it "should redirect_to index" do 
        response.should redirect_to(companies_path)
      end

      it "should have flash notice" do 
        flash[:notice].should eq("Company Abc Info has been created successfully")
      end
    end

    context "Invalid attributes" do 
      before do 
        post :create, :company => {name: "Vinsol"}
      end 

      it "should render template new" do 
        response.should render_template 'new'
      end

      it "should_not redirect_to index" do 
        response.should_not redirect_to(companies_path)
      end

      it "should not have flash notice" do 
        flash[:notice].should_not eq("Company Abc Info has been created successfully")
      end

    end
    
    describe "should_receive methods" do 
      before do 
        @admins = []
        controller.stub(:params_company).and_return(@valid_attributes)
        Company.stub(:new).with(@valid_attributes).and_return(company)
      end
      
      it "should_receive params_company" do 
        controller.should_receive(:params_company).and_return(@valid_attributes)
      end

      it "should_receive new" do 
        Company.should_receive(:new).with(@valid_attributes).and_return(company)
      end

      it "should_receive save" do 
        company.should_receive(:save).and_return(true)
      end

      after do 
        send_request
      end
    end
  end

  describe "UPDATE" do 
    def send_request
      put :update, id: company.id.to_s, company: {"name" => "Demo Test"}
    end

    it_should 'call skip_before_filter :verify_current_company'
    it_should 'call before_action :find_company'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:update, company)
      Company.stub(:where).with(permalink: company.id.to_s).and_return(@companies)
      company.stub(:update_attributes).with({"name" => "Demo Test"}).and_return(true)
    end

    describe "should_receive methods" do 
      before do 
        controller.stub(:params_company).and_return(@valid_attributes)
        company.stub(:update_attributes).with(@valid_attributes).and_return(true)
      end

      it "Company should_receive params_company" do 
        controller.should_receive(:params_company).and_return(@valid_attributes)
      end

      it "should_receive update_attributes" do 
        company.should_receive(:update_attributes).with(@valid_attributes).and_return(true) 
      end

      after do 
        send_request
      end
    end

    context "updated Successfully" do 
      before do 
        company.stub(:update_attributes).with({"name" => "Demo Test"}).and_return(true)
      end

      it "should redirect_to index" do 
        send_request
        response.should redirect_to companies_path
      end

      it "should have flash notice" do 
        send_request
        flash[:notice].should eq("Company Vinsol has been updated successfully")
      end
    end
    
    context "update fail" do 
      before do 
        company.stub(:update_attributes).with({"name" => "Demo Test"}).and_return(false)
      end

      it "should render edit" do 
        send_request
        response.should render_template "edit"
      end

      it "should not have flash notice" do 
        send_request
        flash[:notice].should_not eq("Company Vinsol has been updated successfully")
      end
    end
  end

  describe "change_status" do 
    def send_request
      put :change_status, id: company.id.to_s
    end

    it_should 'call before_action :find_company'
    it_should 'call skip_before_filter :verify_current_company'
    it_should "should_receive authorize_resource"
    
    before do 
      should_authorize(:change_status, company)
      Company.stub(:where).with(permalink: company.id.to_s).and_return(@companies)
      company.stub(:toggle!)
      company.stub(:enabled?).and_return(true)
    end

    it "should_receive toggle!" do 
      company.should_receive(:toggle!).with(:status).and_return(true)
      send_request
    end
  
    it "should redirect_to index" do 
      send_request
      response.should redirect_to companies_path
    end

    it "should have flash notice" do 
      send_request
      flash[:notice].should eq("Company #{company.name} has been #{company.enabled? ? 'enabled' : 'disabled'} successfully")
    end
  end
  
  describe "params_company" do 
    def send_request
      put :update, id: company.id.to_s, company: {"name" => "Demo Test"}
    end

    it_should 'call skip_before_filter :verify_current_company'

    before do 
      should_authorize(:update, company)
      Company.stub(:where).with(permalink: company.id.to_s).and_return(@companies)
      company.stub(:update_attributes).with({"name" => "Demo Test"}).and_return(true)
    end
    
    context "with permitted parameter" do 

      it "should_receive permit" do 
        company.should_receive(:update_attributes).with({"name"=>"Demo Test"})
      end

      after do
        send_request
      end
    end

    context "with unpermitted parameter" do 
      it "should_receive permit" do 
        company.should_receive(:update_attributes).with({"name"=>"Demo Test"})
      end
      
      it "should_not_receive permit with unpermitted data" do 
        company.should_not_receive(:update_attributes).with({"name" => "Demo Test", "test"=>"test"})
      end

      after do
        put :update, id: company.id.to_s, company: {"name" => "Demo Test", "test"=>"test"}
      end
    end

  end
end