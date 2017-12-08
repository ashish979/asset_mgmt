require 'spec_helper'
include ControllerHelper

describe PropertyGroupsController do

  shared_examples_for 'call before_action :find_property_grp' do
    before do 
      request.env["HTTP_REFERER"] = root_path
    end

    describe "should_receive methods" do 
      it "controller should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company should_receive property_groups" do 
        company.should_receive(:property_groups).and_return(@property_groups)
      end

      it "property_groups should_receive where" do 
        @property_groups.should_receive(:where).with(id: property_group.id.to_s).and_return([property_group])
      end

      after do 
        send_request
      end
    end

    context "group found" do
      it "should_not redirect_to back" do 
        send_request
        response.should_not redirect_to root_path
      end

      it "should_not have flash alert" do 
        send_request
        flash[:alert].should_not eq("Property group not found for specified id")
      end
    end

    context "group not found" do
      before do 
        @property_groups.stub(:where).and_return([])
      end

      it "should redirect_to back" do 
        send_request
        response.should redirect_to root_path
      end

      it "should have flash alert" do 
        send_request
        flash[:alert].should eq("Property group not found for specified id")
      end
    end

    it "should assigns instance variable property_group" do 
      send_request
      expect(assigns[:property_group]).to eq(property_group)
    end
  end

  shared_examples_for 'call before_action :find_property_groups' do
    before do 
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:build).and_return(property_group)
      @property_groups.stub(:includes).with(:properties).and_return(@property_groups)
      @property_groups.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@property_groups)
    end

    describe "should_receive methods" do 

      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company should_receive property_groups" do 
        company.should_receive(:property_groups).and_return(@property_groups)
      end
      
      it "should_receive includes" do 
        @property_groups.should_receive(:includes).with(:properties).and_return(@property_groups)
      end

      it "property_groups should_receive paginate" do 
        @property_groups.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@property_groups)
      end

      after do 
        send_request
      end
    end
  end

  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee) }
  let(:property_group) { mock_model(PropertyGroup, save: true, name: "laptop") } 
  let(:property) { mock_model(Property, save: true, name: "Size") } 

  before do
    @admin = employee
    @property_groups = [property_group]
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    @valid_property = { name: "mobile" }
    controller.stub(:logout_if_disable).and_return(true)
    controller.stub(:verify_current_company)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
  end

  describe "INDEX" do 
    def send_request
      get :index , :page => "1"
    end
    
    it_should 'call before_action :find_property_groups'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:index, PropertyGroup)
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:includes).with(:properties).and_return(@property_groups)
      @property_groups.stub(:build).and_return(property_group)
      @property_groups.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@property_groups)
    end

    describe "should_receive methods" do 

      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company should_receive property_groups" do 
        company.should_receive(:property_groups).and_return(@property_groups)
      end

      it "property_groups should_receive build" do 
        @property_groups.should_receive(:build).and_return(property_group)
      end

      it "should_receive find_property_groups" do 
        controller.should_receive(:find_property_groups).and_return(@property_groups)
      end

      after do 
        send_request
      end
    end

    it "should render index" do 
      send_request
      response.should render_template "index"
    end

    it "should assigns instance variable" do 
      send_request
      expect(assigns[:property_group]).to eq(property_group)
    end
  end

  describe "CREATE" do 
    def send_request
      post :create, property_group: @valid_property, page: "1"
    end

    it_should "should_receive authorize_resource"
  
    before do 
      should_authorize(:create, PropertyGroup)
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:build).with(@valid_property).and_return(property_group)
      controller.stub(:params_group_property).and_return(@valid_property)
      @property_groups.stub(:includes).with(:properties).and_return(@property_groups)
      @property_groups.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@property_groups)
    end

    describe "should_receive methods" do 

      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company should_receive property_groups" do 
        company.should_receive(:property_groups).and_return(@property_groups)
      end

      it "property_groups should_receive build" do 
        @property_groups.should_receive(:build).and_return(property_group)
      end

      it "should_receive params_group_property" do 
        controller.should_receive(:params_group_property).and_return(@valid_property)
      end

      it "should_receive save" do 
        property_group.should_receive(:save).and_return(true)
      end

      after do 
        send_request
      end
    end

    it "should assigns instance variable property_group" do 
      send_request
      expect(assigns[:property_group]).to eq(property_group)
    end
    
    context "record not created" do 
      before do
        property_group.stub(:save).and_return(false)
      end

      it "should render template index" do 
        send_request  
        response.should render_template 'index'
      end

      it "should_receive find_property_groups" do 
        controller.should_receive(:find_property_groups)
        send_request
      end

      it_should 'call before_action :find_property_groups'

    end
 
    context "record created" do 
      before do 
        @property_groups.stub(:build).with(@valid_property).and_return(property_group)
      end

      it "should redirect_to index" do 
        send_request
        response.should redirect_to(property_groups_path)
      end

      it "should have a flash notice" do 
        send_request
        flash[:notice].should eq("Property group #{property_group.name} has been created successfully")
      end
    end
  end

  describe "SHOW" do 
    def send_request
      get :show, :id => property_group.id.to_s, page: "1"
    end
    
    it_should 'call before_action :find_property_grp'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:show, property_group)
      @properties = [property]
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:where).with(id: property_group.id.to_s).and_return([property_group])
      property_group.stub(:properties).and_return(@properties)
      @properties.stub(:build).and_return(property)
      @properties.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@properties)
    end
    
    describe "should_receive methods" do 
      
      it "should_receive properties" do 
        property_group.should_receive(:properties).twice.and_return(@properties)
      end

      it "should_receive build" do 
        property.stub(:build).and_return(property)
      end

      it "should_receive paginate" do 
        @properties.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@property_groups)
      end

      after do 
        send_request
      end
    end

    describe "assigns instance variable" do 
      before do 
        send_request
      end

      it "should assign property" do 
        expect(assigns[:property]).to eq(property)
      end

      it "should assign properties" do 
        expect(assigns[:properties]).to eq(@properties)
      end
    end

    it "should render_template show" do 
      send_request
      response.should render_template "show"
    end
  end

  describe "DESTROY" do 
    def send_request
      delete :destroy, :id => property_group.id.to_s
    end
    
    it_should 'call before_action :find_property_grp'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:destroy, property_group)
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:where).with(id: property_group.id.to_s).and_return([property_group])
    end
    
    describe "should_receive methods" do 
    
      it "property_groups should_receive destroy" do 
        property_group.should_receive(:destroy).and_return(true)
      end

      after do 
        send_request
      end
    end

    context "record destroyed" do 
      before do 
        property_group.stub(:destroy).and_return(true)
      end

      it "should redirect_to index" do 
        send_request
        response.should redirect_to property_groups_path
      end

      it "should have a flash notice" do 
        send_request
        flash[:notice].should eq("Property group #{property_group.name} has been deleted successfully")
      end

      it "should not have a flash alert" do 
        send_request
        flash[:alert].should_not eq("Property group #{property_group.name} has not been deleted,please contact support")
      end

    end

    context "record not destroyed" do 
      before do 
        property_group.stub(:destroy).and_return(false)
      end

      it "should redirect_to index" do 
        send_request
        response.should redirect_to property_groups_path
      end

      it "should have a flash alert" do 
        send_request
        flash[:alert].should eq("Property group #{property_group.name} has not been deleted,please contact support")
      end

      it "should not have a flash notice" do 
        send_request
        flash[:notice].should_not eq("Property group #{property_group.name} has been deleted successfully")
      end

    end
  end

  describe "params_group_property" do 
    def send_request
      post :create, property_group: {name: "mobile", created_at: Time.now}, page: "1"
    end
  
    before do 
      should_authorize(:create, PropertyGroup)
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:build).and_return(property_group)
      @property_groups.stub(:includes).with(:properties).and_return(@property_groups)
      @property_groups.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@property_groups)
    end

    it "should_receive build with permitted parameter only" do 
      @property_groups.should_receive(:build).with("name"=>"mobile")
      send_request
    end

    it "should_not_receive build with unpermitted parameter" do 
      @property_groups.should_not_receive(:build).with("name"=>"mobile","created_at"=>Time.now)
      send_request
    end
  end

end
