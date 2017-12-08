require 'spec_helper'
include ControllerHelper

describe AssetTypesController do

  shared_examples_for 'call before_action :find_asset_type' do
    before do 
      company.stub(:asset_types).and_return(@asset_types)
      @asset_types.stub(:includes).with(:property_groups, :asset_type_property_groups).and_return(@asset_types)
      @asset_types.stub(:where).with(id: asset_type.id.to_s).and_return(@asset_types)
    end

    describe "should_receive methods" do 
      it "should_receive current_company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive asset_type" do 
        company.should_receive(:asset_types).and_return(@asset_types)
      end

      it "should_receive includes" do 
        @asset_types.should_receive(:includes).with(:property_groups, :asset_type_property_groups).and_return(@asset_types)
      end

      it "should_receive where" do 
        @asset_types.should_receive(:where).with(id: asset_type.id.to_s).and_return(@asset_types)
      end

      after do 
        send_request
      end
    end

    it "should assign instance variable" do 
      send_request
      expect(assigns[:asset_type]).to eq(asset_type)
    end

    context "asset_type not present" do 
      before do 
        @asset_types.stub(:where).with(id: asset_type.id.to_s).and_return([])  
        request.env["HTTP_REFERER"] = employees_path
      end

      it "should redirect_to referrer" do 
        send_request
        response.should redirect_to employees_path
      end

      it "should have flash alert" do 
        send_request
        flash[:alert].should eq("There is no asset type found for specified id")
      end
    end

    context "asset_type present" do 
      before do 
        request.env["HTTP_REFERER"] = employees_path
      end

      it "should not redirect_to referrer" do 
        send_request
        response.should_not redirect_to employees_path
      end

      it "should not have flash alert" do 
        send_request
        flash[:alert].should_not eq("There is no asset type found for specified id")
      end
    end
  end
  
  shared_examples_for 'call :find_assets' do
    before do 
      company.stub(:asset_types).and_return(@asset_types)
      @asset_types.stub(:includes).with(:property_groups, :assets).and_return(@asset_types)
      @asset_types.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@asset_types)
    end

    describe "should_receive methods" do 
      it "should_receive current_company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive asset_type" do 
        company.should_receive(:asset_types).and_return(@asset_types)
      end

      it "should_receive includes" do 
        @asset_types.should_receive(:includes).with(:property_groups, :assets).and_return(@asset_types)
      end

      it "should_receive where" do 
        @asset_types.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@asset_types)
      end

      after do 
        send_request
      end
    end

    it "should assign instance variable" do 
      send_request
      expect(assigns[:asset_types]).to eq(@asset_types)
    end
  end

  shared_examples_for 'call :build_asset_type_property_groups' do
    context "asset_type_property_groups present" do 
      describe "should_receive methods" do 
        it "should_receive asset_type_property_groups" do 
          asset_type.should_receive(:asset_type_property_groups).twice.and_return(@asset_type_property_groups)
        end
        
        it "should_receive current_company" do 
          controller.should_receive(:current_company).and_return(company)
        end

        it "should_receive property_groups" do 
          company.should_receive(:property_groups).and_return(@property_groups)
        end

        it "should_receive where" do 
          @property_groups.should_receive(:where).with(["id NOT IN (?)", [asset_type_property_group.property_group_id]]).and_return(@property_groups)
        end
        
        # it "should_receive property_groups" do 
        #   asset_type.should_receive(:property_groups).and_return(@property_groups)
        # end

        it "should_receive collect" do 
          @property_groups.should_receive(:collect).and_return([asset_type_property_group.id])
        end

        it "should_receive asset_type_property_groups" do 
          property_group.should_receive(:asset_type_property_groups).and_return(@asset_type_property_groups)
        end

        it "should_receive build" do 
          @asset_type_property_groups.should_receive(:build).and_return(asset_type_property_group)
        end
        
        after do 
          send_request
        end
      end

      it "should assign instance variable asset_type_property_groups" do 
        send_request
        expect(assigns[:asset_type_property_groups]).to eq([asset_type_property_group, asset_type_property_group])
      end
    end

    context "asset_type_property_groups not present" do 
      before do 
        asset_type.stub(:asset_type_property_groups).and_return([])
        @property_groups.stub(:where).and_return([])
      end

      describe "should_receive methods" do 
      
        it "should_receive current_company" do 
          controller.should_receive(:current_company).and_return(company)
        end

        it "should_receive property_groups" do 
          company.should_receive(:property_groups).and_return(@property_groups)
        end

        it "should_receive asset_type_property_groups" do 
          property_group.should_receive(:asset_type_property_groups).and_return(@asset_type_property_groups)
        end

        it "should_receive build" do 
          @asset_type_property_groups.should_receive(:build).and_return(asset_type_property_group)
        end
        
        after do 
          send_request
        end
      end

      it "should assign instance variable asset_type_property_groups" do 
        send_request
        expect(assigns[:asset_type_property_groups]).to eq([asset_type_property_group])
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
  let(:asset_type_property_group){mock_model(AssetTypePropertyGroup) } 

  before do 
    @admin = employee
    @asset_types = [asset_type]
    @valid_attributes = {:name => "black"}
    @property_groups = [property_group]
    @asset_type_property_groups = [asset_type_property_group]
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    controller.stub(:logout_if_disable).and_return(true)
    controller.stub(:verify_current_company)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
    asset_type_property_group.stub(:property_group_id).and_return(1)
  end

  describe "INDEX" do 
    def send_request
      get :index, page: "1"
    end

    it_should 'call :find_assets'
    it_should 'call :build_asset_type_property_groups'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:index, AssetType)
      company.stub(:asset_types).and_return(@asset_types)
      @asset_types.stub(:build).and_return(asset_type)
      @asset_types.stub(:includes).with(:property_groups, :assets).and_return(@asset_types)
      @asset_types.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@asset_types)
      asset_type.stub(:asset_type_property_groups).and_return(@asset_type_property_groups)
      property_group.stub(:asset_type_property_groups).and_return(@asset_type_property_groups)
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:where).with(["id NOT IN (?)", [asset_type_property_group.property_group_id]]).and_return(@property_groups)
      asset_type.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:pluck).and_return([property_group.id])
      @asset_type_property_groups.stub(:build).and_return(asset_type_property_group)
    end
    
    describe "should_receive methods" do 

      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive asset_types" do 
        company.should_receive(:asset_types).and_return(@asset_types)
      end

      it "should_receive build" do 
        @asset_types.should_receive(:build).and_return(asset_type)
      end
      
      it "should_receive build_asset_type_property_groups" do 
        controller.should_receive(:build_asset_type_property_groups)
      end

      it "should_receive find_assets" do 
        controller.should_receive(:find_assets)
      end

      after do 
        send_request
      end
    end

    it "should assign instance variable asset_type" do 
      send_request
      expect(assigns[:asset_type]).to eq(asset_type)
    end
    
    it "should render_template index" do 
      send_request
      response.should render_template "index"
    end
  end
  
  describe "SHOW" do 
    def send_request
      xhr :get, :show, id: asset_type.id.to_s
    end

    it_should 'call before_action :find_asset_type'
    it_should 'call :build_asset_type_property_groups'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:show, asset_type)
      company.stub(:asset_types).and_return(@asset_types)
      @asset_types.stub(:includes).with(:property_groups, :asset_type_property_groups).and_return(@asset_types)
      @asset_types.stub(:where).with(id: asset_type.id.to_s).and_return(@asset_types)
      asset_type.stub(:asset_type_property_groups).and_return(@asset_type_property_groups)
      property_group.stub(:asset_type_property_groups).and_return(@asset_type_property_groups)
      asset_type.stub(:property_groups).and_return(@property_groups)
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:where).with(["id NOT IN (?)", [asset_type_property_group.property_group_id]]).and_return(@property_groups)
      @property_groups.stub(:pluck).and_return([property_group.id])
      @asset_type_property_groups.stub(:build).and_return(asset_type_property_group)
    end
    
    context "request is html" do
      def send_html_request
        get :show, id: asset_type.id.to_s
      end

      before do 
        request.env["HTTP_REFERER"] = employees_path
      end

      it "should redirect to referrer" do 
        send_html_request
        response.should redirect_to employees_path
      end

      it "should_not_receive build_asset_type_property_groups" do 
        controller.should_not_receive(:build_asset_type_property_groups)
        send_html_request
      end
    end

    context "request is xhr" do
      
      it "should render_template show" do 
        send_request
        response.should render_template "show"
      end

      it "should_receive build_asset_type_property_groups" do 
        controller.should_receive(:build_asset_type_property_groups)
        send_request
      end
    end

  end

  describe "CREATE" do
    def send_request
      post :create, asset_type: {name: "black", property_groups: [property_group.id.to_s]}, page: 1
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:create, AssetType)
      controller.stub(:params_asset_type).and_return(@valid_attributes)
      company.stub(:asset_types).and_return(@asset_types)
      @asset_types.stub(:build).and_return(asset_type)
      asset_type.stub(:assign_property_groups).with([property_group.id.to_s]).and_return(true)
      @asset_types.stub(:includes).with(:property_groups, :assets).and_return(@asset_types)
      @asset_types.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@asset_types)
      asset_type.stub(:asset_type_property_groups).and_return(@asset_type_property_groups)
      property_group.stub(:asset_type_property_groups).and_return(@asset_type_property_groups)
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:where).with(["id NOT IN (?)", [asset_type_property_group.property_group_id]]).and_return(@property_groups)
      asset_type.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:pluck).and_return([property_group.id])
      @asset_type_property_groups.stub(:build).and_return(asset_type_property_group)
    end
    
    it "should assign asset_type" do 
      send_request
      expect(assigns[:asset_type]).to eq(asset_type)
    end
     
    describe "should_receive methods" do 
      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
        send_request
      end 

      it "should_receive params_asset_type" do 
        controller.should_receive(:params_asset_type).and_return(@valid_attributes)
        send_request
      end

      it "should_receive asset_types" do 
        company.should_receive(:asset_types).and_return(@asset_types)
        send_request
      end

      it "should_receive build" do 
        @asset_types.should_receive(:build).and_return(asset_type)
        send_request
      end
      
      it "should_receive save" do 
        asset_type.should_receive(:save).and_return(true)
        send_request
      end
    end
    
    context "asset_type created" do 
      before do 
        asset_type.stub(:save).and_return(true)
      end

      it "should redirect_to index page" do 
        send_request
        response.should redirect_to asset_types_path 
      end

      it "should have a flash notice" do 
        send_request
        flash[:notice].should eq("Asset type laptop has been created successfully")
      end
    end

    context "asset_type not created" do
      
      it_should 'call :find_assets'
      it_should 'call :build_asset_type_property_groups'

      before do 
        asset_type.stub(:save).and_return(false)
      end

      it "should_receive find_assets" do 
        controller.should_receive(:find_assets)
        send_request
      end

      it "should_receive build_asset_type_property_groups" do 
        controller.should_receive(:build_asset_type_property_groups)
        send_request
      end

      it "should render template index" do 
        send_request
        response.should render_template "index"
      end
    end
  end

  describe "update" do 
    def send_request
      put :update, asset_type: {property_groups: property_group.id}, id: asset_type.id, page: 1
    end

    it_should 'call before_action :find_asset_type'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:update, asset_type)
      company.stub(:asset_types).and_return(@asset_types)
      @asset_types.stub(:includes).with(:property_groups, :asset_type_property_groups).and_return(@asset_types)
      @asset_types.stub(:where).with(id: asset_type.id.to_s).and_return(@asset_types)
      controller.stub(:params_asset_type).and_return(@valid_attributes)
      asset_type.stub(:update_attributes).with(@valid_attributes).and_return(true)
      @asset_types.stub(:includes).with(:property_groups, :assets).and_return(@asset_types)
      @asset_types.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@asset_types)
      asset_type.stub(:asset_type_property_groups).and_return(@asset_type_property_groups)
      property_group.stub(:asset_type_property_groups).and_return(@asset_type_property_groups)
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:where).with(["id NOT IN (?)", [asset_type_property_group.property_group_id]]).and_return(@property_groups)
      asset_type.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:pluck).and_return([property_group.id])
      @asset_type_property_groups.stub(:build).and_return(asset_type_property_group)
    end

    it "should_receive params_asset_type" do 
      controller.should_receive(:params_asset_type).and_return(@valid_attributes)
      send_request
    end

    it "should_receive update_attributes" do 
      asset_type.should_receive(:update_attributes).with(@valid_attributes).and_return(true)
      send_request
    end
  
    context "recoed updated" do 
      it "should have flash message" do 
        send_request
        flash[:notice].should eq("Asset type #{asset_type.name} has been updated successfully")
      end

      it "should redirect_to index path" do 
        send_request
        response.should redirect_to asset_types_path
      end
    end

    context "recoed not updated" do 
      
      it_should 'call :find_assets'
      it_should 'call :build_asset_type_property_groups'
      
      before do 
        asset_type.stub(:update_attributes).and_return(false)
      end

      it "should_receive find_assets" do 
        controller.should_receive(:find_assets)
        send_request
      end

      it "should_receive build_asset_type_property_groups" do 
        controller.should_receive(:build_asset_type_property_groups)
        send_request
      end

      it "should render index" do 
        send_request
        response.should render_template "index"
      end
    end
  end

  describe "DESTROY" do 
    def send_request
      delete :destroy, id: asset_type.id.to_s
    end

    it_should "call before_action :find_asset_type"
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:destroy, asset_type)
      company.stub(:asset_types).and_return(@asset_types)
      @asset_types.stub(:where).with(id: asset_type.id.to_s).and_return(@asset_types)
      asset_type.stub(:property_groups).and_return(@property_groups)
      @asset_types.stub(:includes).and_return(@asset_types)
      @property_groups.stub(:delete_all).and_return(true)
    end

    describe "should_receive methods" do 
      it "should_receive destroy" do 
        asset_type.should_receive(:destroy).and_return(true)
        send_request
      end
    end

    context "recodrd deleted" do 
      before do 
        asset_type.stub(:destroy).and_return(true)
      end

      it "should redirect_to asset_types_path" do 
        send_request
        response.should redirect_to asset_types_path
      end

      it "should have flash" do 
        send_request
        flash[:notice].should eq("Asset type #{asset_type.name} has been deleted successfully")
      end
    end

    context "recodrd not deleted" do 
      before do 
        asset_type.stub(:destroy).and_return(false)
      end

      it "should redirect_to asset_types_path" do 
        send_request
        response.should redirect_to asset_types_path
      end

      it "should have flash" do 
        send_request
        flash[:alert].should eq("There is some problem,please contact support")
      end
    end
  end

  describe "params_asset_type" do 
    def send_request
      put :update, asset_type: {name: "Demo"}, id: asset_type.id, page: 1
    end

    before do 
      should_authorize(:update, asset_type)
      company.stub(:asset_types).and_return(@asset_types)
      @asset_types.stub(:includes).with(:property_groups, :asset_type_property_groups).and_return(@asset_types)
      @asset_types.stub(:where).with(id: asset_type.id.to_s).and_return(@asset_types)
      asset_type.stub(:update_attributes).with(@valid_attributes).and_return(true)
      @asset_types.stub(:includes).with(:property_groups, :assets).and_return(@asset_types)
      @asset_types.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@asset_types)
      asset_type.stub(:asset_type_property_groups).and_return(@asset_type_property_groups)
      property_group.stub(:asset_type_property_groups).and_return(@asset_type_property_groups)
      company.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:where).with(["id NOT IN (?)", [asset_type_property_group.property_group_id]]).and_return(@property_groups)
      asset_type.stub(:property_groups).and_return(@property_groups)
      @property_groups.stub(:pluck).and_return([property_group.id])
      @asset_type_property_groups.stub(:build).and_return(asset_type_property_group)
    end

    context "with permitted parameter" do 

      it "should_receive permit" do 
        asset_type.should_receive(:update_attributes).with({"name"=>"Demo"})
      end

      after do
        send_request
      end
    end

    context "with unpermitted parameter" do 
      it "should_receive permit" do 
        asset_type.should_receive(:update_attributes).with({"name"=>"Demo"})
      end
      
      it "should_not_receive permit with unpermitted data" do 
        asset_type.should_not_receive(:update_attributes).with({"name"=>"Demo","created_at"=>Time.now})
      end

      after do
        put :update, asset_type: {name: "Demo", created_at: Time.now}, id: asset_type.id, page: 1
      end
    end
  end

end
