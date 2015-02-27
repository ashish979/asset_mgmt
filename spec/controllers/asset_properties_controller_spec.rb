require 'spec_helper'
include ControllerHelper

describe AssetPropertiesController do
  
  shared_examples_for 'call before_action :find_asset_property' do
    before do 
      AssetProperty.stub(:where).with(id: asset_property.id.to_s).and_return([asset_property])
    end

    it "should_receive where" do 
      AssetProperty.should_receive(:where).with(id: asset_property.id.to_s).and_return([asset_property])
      send_request  
    end

    it "should assign asset_property" do 
      send_request
      expect(assigns[:asset_property]).to eq(asset_property)
    end
    
    context "asset type is blank" do 
      before do 
        AssetProperty.stub(:where).with(id: asset_property.id.to_s).and_return([])
      end

      it "should have flash alert" do 
        send_request
        flash[:alert].should eq("There is no asset type with id: #{asset_property.id}")
      end

      it "should render partial find_asset_property" do 
        send_request
        response.should render_template 'asset_properties/_find_asset_property'
      end
    end

    context "asset type is present" do 
      before do 
        AssetProperty.stub(:where).with(id: asset_property.id.to_s).and_return([asset_property])
      end

      it "should not have flash alert" do 
        send_request
        flash[:alert].should_not eq("There is no asset type with id: #{asset_property.id}")
      end

      it "should not render partial find_asset_property" do 
        send_request
        response.should_not render_template 'asset_properties/_find_asset_property'
      end
    end
  end

  shared_examples_for 'call before_action for asset_properties :find_asset' do
    describe "should_receive methods" do 
      it "controller should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive assets" do 
        company.should_receive(:assets).and_return(@assets)
      end

      it "should_receive where" do 
        @assets.stub(:where).with(id: asset.id.to_s).and_return(@assets)
      end

      it "should_receive includes" do 
        @assets.should_receive(:includes).with(:asset_properties).and_return(@assets)
      end

      after do 
        send_request
      end
    end

    it "should assign asset" do 
      send_request
      expect(assigns[:asset]).to eq(asset)
    end

    context "assets not present" do 
      before do 
        company.stub(:assets).and_return(@assets)
        @assets.stub(:where).with(id: asset.id.to_s).and_return(@assets)
        @assets.stub(:includes).and_return([])
        send_request
      end

      it "should redirect_to root_path" do 
        response.should redirect_to root_path
      end

      it "should have flash alert" do 
        flash[:alert].should eq("Record not found")
      end
    end

    context "assets present" do 
      before do 
        send_request
      end

      it "should not redirect_to root_path" do 
        response.should_not redirect_to root_path
      end

      it "should not have flash alert" do 
        flash[:alert].should_not eq("Record not found")
      end
    end
  end

  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee) }
  let(:property_group) { mock_model(PropertyGroup, save: true, name: "laptop") } 
  let(:property) { mock_model(Property, save: true, name: "Size") } 
  let(:property1) { mock_model(Property, save: true, name: "Color") } 
  let(:asset_type)  { mock_model(AssetType, :save => true, "name"=>"laptop", "company_id"=>company.id) }
  let(:asset)  { mock_model(Asset, :save => true,"asset_type_id"=>asset_type.id, "name"=>"Test Name", "status"=>"spare", "brand"=> "HP", "currency_unit"=>"&#8377;", "cost"=>"100.0", "serial_number"=>"YUIYIU78sdf789IU", "vendor"=>"Test", "purchase_date"=>"29/09/2011", "description"=>"Test Desc", "additional_info"=>"Test ADD Info") }
  let(:asset_property){mock_model(AssetProperty, :save => true, :asset_id => asset.id, :property_id => property.id, :property_group_id => property_group.id, :value => "red") }
  
  before do 
    @admin = employee
    @asset_properties = [asset_property]
    @assets = [asset]
    @valid_attributes = {:value => "black"}
    @property_groups = [property_group]
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
      xhr :get, :index, id: asset.id.to_s
    end

    it_should "should_receive authorize_resource"
    it_should 'call before_action for asset_properties :find_asset'

    before do 
      should_authorize(:index, AssetProperty)
      company.stub(:assets).and_return(@assets)
      @assets.stub(:where).with(id: asset.id.to_s).and_return(@assets)
      @assets.stub(:includes).with(:asset_properties).and_return(@assets)
      asset.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:includes).with(:properties).and_return(@property_groups)
    end

    describe "should_receive methods" do 

      it "should_receive property_groups" do 
        asset.should_receive(:property_groups).and_return(@property_groups)
      end

      it "should_receive includes" do 
        @property_groups.should_receive(:includes).with(:properties).and_return(@property_groups)
      end
      after do 
        send_request
      end
    end

    describe "instance variables assignment" do 
      before do 
        send_request
      end
      it "should assign asset_property_groups" do 
        expect(assigns[:asset_property_groups]).to eq(@property_groups)
      end
    end

    describe "render view" do 
      it "should render_template index" do 
        send_request
        response.should render_template "index"
      end
    end
  end

  describe "EDIT" do
    def send_request
      get :edit, id: asset_property.id.to_s
    end 

    it_should "should_receive authorize_resource"    

    before do 
      should_authorize(:edit, AssetProperty)
      company.stub(:asset_properties).and_return(@asset_properties)
      @asset_properties.stub(:where).with(id: asset_property.id.to_s).and_return([asset_property])
    end

    describe "should_receive methods" do 
      it "should_receive asset_properties" do 
        company.should_receive(:asset_properties).and_return(@asset_properties)
      end

      it "should_receive where" do 
        @asset_properties.stub(:where).with(id: asset_property.id.to_s).and_return([asset_property])
      end

      after do 
        send_request
      end
    end

    describe "assign instance variables" do 
      it "should assign asset_property" do 
        send_request
        expect(assigns[:asset_property]).to eq(asset_property)
      end
    end

    describe "render views" do 
      it "should render template edit" do 
        send_request
        response.should render_template "edit"
      end
    end
  end

  describe "UPDATE" do 
    def send_request
      xhr :put ,:update, id: asset_property.id
    end

    it_should 'call before_action :find_asset_property'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:update, asset_property)
      AssetProperty.stub(:where).with(id: asset_property.id.to_s).and_return([asset_property])
      controller.stub(:params_asset_property).and_return(@valid_attributes)
      asset_property.stub(:property).and_return(property)
      asset_property.stub(:update_attributes).with(@valid_attributes).and_return(true)
      asset_property.stub(:asset).and_return(asset)
    end
    
    describe "should_receive methods" do 
      it "should_receive params_asset_property" do 
        controller.should_receive(:params_asset_property).and_return(@valid_attributes)
      end

      it "should_receive update_attributes" do 
        asset_property.should_receive(:update_attributes).with(@valid_attributes).and_return(true)
      end

      after do 
        send_request
      end
    end

    context "xhr request" do     
      context "record updated" do 
        before do 
          asset_property.stub(:update_attributes).with(@valid_attributes).and_return(true)
        end

        it "should have flash notice" do 
          send_request
          flash[:notice].should eq("Property #{asset_property.property.try(:name)} has been updated successfully")
        end
      end

      context "record not updated" do 
        before do 
          asset_property.stub(:update_attributes).with(@valid_attributes).and_return(false)
        end

        it "should have flash alert" do 
          send_request
          flash[:alert].should eq("Value of property #{asset_property.property.try(:name)} not updated")
        end
      end

      it "should render_template update" do 
        send_request
        response.should render_template "update"
      end
    end

    context "html request" do     
      def send_request
        put :update, id: asset_property.id
      end

      context "record updated" do 
        before do 
          asset_property.stub(:update_attributes).with(@valid_attributes).and_return(true)
        end

        it "should have flash notice" do 
          send_request
          flash[:notice].should eq("Property Size has been updated successfully")
        end
      end

      context "record not updated" do 
        before do 
          asset_property.stub(:update_attributes).with(@valid_attributes).and_return(false)
        end

        it "should have flash alert" do 
          send_request
          flash[:alert].should eq("Value of property #{asset_property.property.try(:name)} not updated")
        end
      end

      it "should redirect_to edit_asset_path" do 
        send_request
        response.should redirect_to edit_asset_type_asset_path(asset_property, asset_property.asset)
      end
    end
  end

  describe "DESTROY" do 
    def send_request
      xhr :delete ,:destroy, id: asset_property.id
    end

    it_should 'call before_action :find_asset_property'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:destroy, asset_property)
      AssetProperty.stub(:where).with(id: asset_property.id.to_s).and_return([asset_property])
      asset_property.stub(:asset).and_return(asset)
      asset.stub(:property_groups).and_return(@property_groups)
      asset_property.stub(:property).and_return(property)
      @property_groups.stub(:includes).with(:properties).and_return(@property_groups)
      asset_property.stub(:destroy).and_return(true)
    end

    it "should assign asset" do 
      send_request
      expect(assigns[:asset]).to eq(asset)
    end

    context "should_receive methods" do 
      it "should_receive asset" do 
        asset_property.should_receive(:asset).and_return(asset)
        send_request
      end

      it "should_receive property_group" do 
        asset.should_receive(:property_groups).and_return(@property_groups)
      end

      it "should_receive includes" do 
        @property_groups.should_receive(:includes).with(:properties).and_return(@property_groups)
      end

      after do 
        send_request
      end
    end

    context "request is xhr" do 
      it "should set flash notice" do 
        send_request
        flash[:notice].should eq("Property #{asset_property.property.try(:name)} has been removed successfully")
      end

      it "should render destroy" do 
        send_request
        response.should render_template "destroy"
      end
    end

    context "request is html" do 
      def send_request
        delete :destroy, id: asset_property.id
      end

      it "should redirect to index path" do 
        send_request
        response.should redirect_to asset_properties_index_path(asset)
      end

      it "should have a flash notice" do 
        send_request
        flash[:notice].should eq("Property #{asset_property.property.try(:name)} has been removed successfully")
      end
    end
  end
  
  describe "params_asset_property" do 
    def send_request
      xhr :put ,:update, id: asset_property.id, asset_property: {value: "abc"}
    end

    before do 
      should_authorize(:update, asset_property)
      AssetProperty.stub(:where).and_return([asset_property])
      asset_property.stub(:property).and_return(property)
      asset_property.stub(:update_attributes).and_return(true)
    end
    
    context "with permitted parameter" do 
      it "should_receive permit" do 
        asset_property.should_receive(:update_attributes).with({"value"=>"abc"})
        send_request
      end
    end

    context "with unpermitted parameter" do 
      it "should_receive permit" do 
        asset_property.should_receive(:update_attributes).with({"value"=>"abc"})
      end
      
      it "should_not_receive permit with unpermitted data" do 
        asset_property.should_not_receive(:update_attributes).with({"value"=>"abc","created_at"=>Time.now})
      end

      after do 
        xhr :put ,:update, id: asset_property.id, asset_property: {value: "abc", created_at: Time.now}
      end
    end

  end

  describe "autocomplete" do 
    it "should define autocomplete method" do 
      AssetPropertiesController.method_defined?(:autocomplete_property_name).should be_true
    end
  end
end
