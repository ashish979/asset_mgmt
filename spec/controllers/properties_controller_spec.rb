require 'spec_helper'
include ControllerHelper

describe PropertiesController do

  shared_examples_for 'call before_action :find_property_group' do

    describe "should_receive methods" do 

      it "controller should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company should_receive asset" do 
        company.should_receive(:property_groups).and_return(@property_groups)
      end

      it "property_groups should_receive where" do 
        @property_groups.should_receive(:where).with(id: property_group.id.to_s).and_return([property_group])
      end

      after do 
        send_request
      end
    end

    it "should assigns instance variable property_group" do 
      send_request
      expect(assigns[:property_group]).to eq(property_group)
    end

    context "group found" do
      it "should_not redirect_to index" do 
        send_request
        response.should_not redirect_to property_groups_path
      end

      it "should_not have flash alert" do 
        send_request
        flash[:alert].should_not eq("Property group not found")
      end
    end

    context "group not found" do
      before do 
        @property_groups.stub(:where).and_return([])
      end

      it "should redirect_to index" do 
        send_request
        response.should redirect_to property_groups_path
      end

      it "should have flash alert" do 
        send_request
        flash[:alert].should eq("Property group not found")
      end
    end
  end

  shared_examples_for 'call before_action :find_property' do
    describe "should_receive methods" do 

      it "controller should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company should_receive asset" do 
        company.should_receive(:properties).and_return(@properties)
      end

      it "assets should_receive where" do 
        @properties.should_receive(:where).with(id: property.id.to_s).and_return(@properties)
      end

      it "should_receive includes" do 
        @properties.should_receive(:includes).with(:property_group).and_return([property])
      end

      after do 
        send_request
      end
    end

    it "should assigns instance variable property" do 
      send_request
      expect(assigns[:property]).to eq(property)
    end

    context "record found" do 
      before do 
        request.env["HTTP_REFERER"] = property_groups_path
      end
      
      it "should not have flash alert" do 
        send_request
        flash[:alert].should_not eq("Property not found for specified id")
      end

      it "should not redirect_to back" do 
        send_request
        response.should_not redirect_to property_groups_path
      end
    end
    
    context "record not found" do 
      before do 
        @properties.should_receive(:includes).with(:property_group).and_return([])
        request.env["HTTP_REFERER"] = property_groups_path
      end

      it "should have flash alert" do 
        send_request
        flash[:alert].should eq("Property not found for specified id")
      end

      it "should redirect_to back" do 
        send_request
        response.should redirect_to property_groups_path
      end
    end
  end

  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee) }
  let(:property_group) { mock_model(PropertyGroup, save: true, name: "laptop") } 
  let(:property) { mock_model(Property, save: true, name: "Size") } 

  before do
    @admin = employee
    @properties = [property]
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    @valid_property = { name: "color", property_group_id: property_group.id }
    controller.stub(:logout_if_disable).and_return(true)
    controller.stub(:verify_current_company)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
  end
    
  describe "CREATE" do 
    def send_request
      post :create, property: @valid_property, property_group_id: property_group.id
    end
    
    it_should 'call before_action :find_property_group'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:create, Property)
      @property_groups = [property_group]
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:where).and_return(@property_groups)
      property_group.stub(:properties).and_return(property)
      controller.stub(:params_property).and_return(@valid_attributes)
      property.stub(:company_id=).and_return(company.id)
      property.stub(:save).and_return(true)
      controller.stub(:params_property).and_return(@valid_property)
      company.stub(:properties).and_return(property)
      property.stub(:build).with(@valid_property).and_return(property)
    end
    
    describe "should_receive methods" do 

      it "should_receive params_property" do 
        controller.should_receive(:params_property).and_return(@valid_property)
      end

      it "company should_receive properties" do 
        property_group.should_receive(:properties).and_return(property)
      end

      it "property should_receive build" do 
        property.should_receive(:build).with(@valid_property).and_return(property)
      end

      it "should_receive company_id" do 
        property.should_receive(:company_id=).and_return(company.id)
      end

      it "should_receive save" do 
        property.should_receive(:save).and_return(true)
      end

      after do 
        send_request
      end
    end

    it "should assigns instance variable property" do 
      send_request
      expect(assigns[:property]).to eq(property)
    end

    context "record created" do 
      before do 
        controller.stub(:params_property).and_return(@valid_property)
        company.stub(:properties).and_return(property)
        property.stub(:build).with(@valid_property).and_return(property)
      end

      it "should redirect_to index" do 
        send_request
        response.should redirect_to(property_group_path(property_group))
      end

      it "should have flash notice" do 
        send_request
        flash[:notice].should eq("Property Size has been created successfully")
      end
    end 

    context "record not created" do 
      def send_request
        post :create, property: @valid_property, page: "1", property_group_id: property_group.id
      end

      before do 
        company.stub(:properties).and_return(property)
        property.stub(:build).and_return(Property.new)
        property.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@properties)
      end
      
      it "should assigns instance variable properties" do 
        send_request
        expect(assigns[:properties]).to eq(@properties)
      end
      
      it "should render template show" do 
        send_request
        response.should render_template 'property_groups/show'
      end

      it "company should_receive properties" do 
        property_group.should_receive(:properties).twice.and_return(property)
        send_request
      end

      it "should_receive paginate" do 
        property.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@properties)
        send_request
      end

      it "should not redirect_to index" do 
        send_request
        response.should_not redirect_to(property_group_path(property_group))
      end

      it "should not have flash notice" do 
        send_request
        flash[:notice].should_not eq("Property Size has been created successfully")
      end
    end
  end

  describe "DESTROY" do 
    def send_request
      delete :destroy, id: property.id.to_s, property_group_id: property_group.id
    end
    
    it_should 'call before_action :find_property'
    it_should "should_receive authorize_resource"     

    before do 
      should_authorize(:destroy, property)
      company.stub(:properties).and_return(@properties)
      @properties.stub(:where).with(id: property.id.to_s).and_return(@properties)
      @properties.stub(:includes).with(:property_group).and_return(@properties)
      property.stub(:property_group).and_return(property_group)
    end
    
    it "should assigns instance variable property_group" do 
      send_request
      expect(assigns[:property_group]).to eq(property_group)
    end

    describe "should_receive methods" do 
      it "should_receive property_groups" do 
        property.should_receive(:property_group).and_return(property_group)
      end

      it "should_receive destroy" do 
        property.should_receive(:destroy).and_return(true)
      end

      after do 
        send_request
      end
    end
    
    context "property deleted" do 
      before do 
        property.stub(:destroy).and_return(true)
      end

      it "should redirect_to properties_path" do 
        send_request
        response.should redirect_to property_group_path(property_group)
      end

      it "should have a flash notice" do 
        send_request
        flash[:notice].should eq("Property #{property.name} has been deleted successfully")
      end

      it "should not have a flash alert" do 
        send_request
        flash[:alert].should_not eq("Property could not be deleted")
      end
    end

    context "property not deleted" do 
      before do 
        property.stub(:destroy).and_return(false)
      end

      it "should redirect_to properties_path" do 
        send_request
        response.should redirect_to property_group_path(property_group)
      end

      it "should have a flash alert" do 
        send_request
        flash[:alert].should eq("Property could not be deleted")
      end

      it "should not have a flash notice" do 
        send_request
        flash[:notice].should_not eq("Property #{property.name} has been deleted successfully")
      end
    end
  end

  describe "params_property" do 
    def send_request
      post :create, property: {name: "color", property_group_id: property_group.id}, property_group_id: property_group.id
    end
    
    before do 
      should_authorize(:create, Property)
      @property_groups = [property_group]
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:where).and_return(@property_groups)
      property_group.stub(:properties).and_return(property)
      property.stub(:company_id=).and_return(company.id)
      property.stub(:save).and_return(true)
      company.stub(:properties).and_return(property)
      property.stub(:build).and_return(property)
    end

    context "with permitted parameter" do 

      it "should_receive permit" do 
        property.should_receive(:build).with({"name"=>"color"})
      end

      after do
        send_request
      end
    end

    context "with unpermitted parameter" do 
      it "should_receive permit" do 
        property.should_receive(:build).with({"name"=>"color"})
      end
      
      it "should_not_receive permit with unpermitted data" do 
        property.should_not_receive(:build).with({name: "color", property_group_id: property_group.id})
      end

      after do
        post :create, property: {name: "color", property_group_id: property_group.id}, property_group_id: property_group.id
      end
    end

  end

end
