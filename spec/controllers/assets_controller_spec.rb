require 'spec_helper'
include ControllerHelper

describe AssetsController do

  shared_examples_for 'call before_action :find_asset' do
    describe "should_receive methods" do 
      it "controller should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company should_receive asset" do 
        company.should_receive(:assets).and_return(@assets)
      end

      it "assets should_receive where" do 
        @assets.should_receive(:where).with(id: asset.id.to_s).and_return([asset])
      end

      after do 
        send_request
      end
    end

    context "assets not present" do 
      before do 
        company.stub(:assets).and_return(@assets)
        @assets.stub(:where).with(id: asset.id.to_s).and_return([])
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

  shared_examples_for 'call method :find_asset_type' do
    describe "should_receive methods" do 
      it "should_receive current_company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive asset_types" do 
        company.should_receive(:asset_types).and_return(@asset_types)
      end

      it "should_receive where" do 
        @asset_types.should_receive(:where).with(id: asset_type.id.to_s).and_return(@asset_types)
      end

      after do 
        send_request
      end
    end

    describe "assigns instance varaibles asset_type" do 
      it "should assign instance varaibles" do
        send_request
        expect(assigns[:asset_type]).to eq(asset_type)
      end
    end
  end

  shared_examples_for 'call before_action :find_unscoped_asset' do
    describe "should_receive methods" do 
      it "Asset should_receive unscoped" do 
        Asset.should_receive(:unscoped).and_return(@assets)
      end

      it "@assets should_receive where" do 
        @assets.should_receive(:where).with(company_id: company.id, id: asset.id.to_s).and_return(@assets)
      end

      after do 
        send_request
      end
    end

    context "assets not present" do 
      before do 
        Asset.should_receive(:unscoped).and_return(@assets)
        @assets.stub(:where).and_return([])
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

  let(:company) { mock_model(Company,:save => true, :id => 1) }
  let(:aem) { mock_model(Assignment, :save => true, :employee_id => 4, :asset_id => 1, :date_returned => DateTime.now, :remark => "assign") }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com","company_id"=>company.id) }
  let(:asset_type)  { mock_model(AssetType, :save => true, "name"=>"laptop", "company_id"=>company.id) }
  let(:asset)  { mock_model(Asset, :save => true,"asset_type_id"=>asset_type.id, "name"=>"Test Name", "status"=>"spare", "brand"=> "HP", "type"=>"Laptop", "currency_unit"=>"&#8377;", "cost"=>"100.0", "serial_number"=>"YUIYIU78sdf789IU", "vendor"=>"Test", "purchase_date"=>"29/09/2011", "description"=>"Test Desc", "additional_info"=>"Test ADD Info","company_id"=>company.id) }
  let(:comment) { mock_model(Comment, :save => true, "body"=>"Test comment") }
  let(:property_group) { mock_model(PropertyGroup, :save => true, "name"=>"Test comment", "company_id"=>company.id) }
  let(:asset_property) { mock_model(AssetProperty) }
  let(:audit) { mock_model(Audited::Adapters::ActiveRecord::Audit) }
  let(:file_upload) { mock_model(FileUpload) }
  let(:ticket) { mock_model(Ticket) }

  before do
    @admin = employee
    @valid_attributes = {"asset_type_id"=>asset_type.id, "status"=>"spare", "brand"=>"HP", "name"=>"test", "currency_unit"=>"&#8377;", "cost"=>"57557", "serial_number"=>"6ggvg", "vendor"=>"vjb", "purchase_date"=>"23/04/2013", "additional_info"=>"chgj", "description"=>"jvjv", "tags_field"=>""}
    @aems = [aem]
    @comments = [comment]
    @assets = [asset]
    @tickets = [ticket]
    @file_uploads = [file_upload]
    @asset_properties = [asset_property]
    @asset_types = [asset_type]
    @audits = [audit]
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    controller.stub(:logout_if_disable).and_return(true)
    controller.stub(:verify_current_company)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
    @tag = Tag.create(name: 'Test')
    asset.stub(:asset_type).and_return(asset_type)
  end
  
  describe "INDEX" do 
    def send_request type=nil 
      get :index , :type => type, :page => "1"
    end

    def send_request_with_asset_type(asset_type_id)
      get :index, page: "1", asset_type_id: asset_type_id
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:index, Asset)
      company.stub(:assets).and_return(@assets)
      @assets.stub(:where).with(asset_type_id: asset_type.id.to_s).and_return(@assets)
      Asset.stub(:retired_assets).with(company).and_return(@assets)
      @assets.stub(:order).with('id asc').and_return(@assets)
      @assets.stub(:includes).with(:asset_type, :assignments, :active_assignments => :employee).and_return(@assets)
      @assets.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@assets)
    end
    
    context "params[:asset_type_id] present" do 
      describe "should_receive methods" do 

        it "should_receive current_company" do 
          controller.stub(:current_company).and_return(company)
        end

        it "should_receive assets" do 
          company.should_receive(:assets).and_return(@assets)
        end

        it "should_receive where" do 
          @assets.should_receive(:where).with(asset_type_id: asset_type.id.to_s).and_return(@assets)
        end

        after do 
          send_request_with_asset_type(asset_type.id)
        end
      end

      it "should assigns instance varaibles assets" do 
        send_request_with_asset_type(asset_type.id)
        expect(assigns[:assets]).to eq(@assets)
      end
    end

    context "params[:asset_type_id] not present" do

      it "should_not_receive where" do 
        @assets.should_not_receive(:where)
      end

      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive assets" do 
        company.should_receive(:assets)
      end

      after do 
        send_request
      end
    end

    context "params[:type] is retired" do 
      describe "should_receive methods" do 
        it "Asset should_receive unscoped" do 
          Asset.should_receive(:retired_assets).with(company).and_return(@assets)
        end
        
        it "should_receive order" do 
          @assets.should_receive(:order).with('id asc').and_return(@assets)  
        end

        after do 
          send_request('retired')
        end
      end

      describe "assigns instance varaibles" do 
        it "should assign assets" do 
          send_request('retired')
          expect(assigns[:assets]).to eq(@assets)
        end
      end
    end

    context "params[:type] is not 'retired'" do
      before do 
        company.stub(:assets).and_return(@assets)
      end

      describe "should_receive methods" do 
        it "should_receive company" do 
          controller.should_receive(:current_company).and_return(company)
        end

        it "should_receive assets" do 
          company.should_receive(:assets).and_return(@assets)
        end

        after do 
          send_request
        end
      end

      describe "assigns instance varaibles" do 
        it "should assign assets" do 
          send_request
          expect(assigns[:assets]).to eq(@assets)
        end
      end
    end

    context "params sort is present" do 
      def send_request
        get :index , :sort => 'id desc' , :page => "1"
      end

      before do 
        @assets.stub(:order).with('id desc').and_return(@assets)
      end

      it "should receive order" do 
        @assets.should_receive(:order).with('id desc').and_return(@assets)
        send_request
      end

      it "should assigns assets" do 
        send_request
        expect(assigns[:assets]).to eq(@assets)
      end
    end

    context "params sort is not present" do 
      it "should not  receive order" do 
        @assets.should_not_receive(:order)
        send_request
      end
    end
  
    describe "should_receive in all conditions" do 
      it "should_receive includes" do 
        @assets.should_receive(:includes).with(:asset_type, :assignments, :active_assignments => :employee).and_return(@assets)
        send_request
      end

      it "should_receive includes" do 
        @assets.should_receive(:includes).with(:asset_type, :assignments, :active_assignments => :employee).and_return(@assets)
        send_request('retired')
      end

      it "should_receive includes" do 
        @assets.should_receive(:includes).with(:asset_type, :assignments, :active_assignments => :employee).and_return(@assets)
        send_request_with_asset_type(asset_type.id)
      end

      it "receive paginate" do
        @assets.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@assets)
        send_request_with_asset_type(asset_type.id)
      end

      it "receive paginate" do
        @assets.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@assets)
        send_request
      end

      it "receive paginate" do
        @assets.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@assets)
        send_request('retired')
      end
    end

    context "html request" do 
      before do 
        send_request(asset_type.id.to_s)
      end

      it "should render index" do   
        response.should render_template "index"
      end
    end

    context "xhr request" do 
      before do 
        xhr :get, :index , :type => asset_type.id, :page => "1"
      end

      it "should render index" do   
        response.should render_template "index"
      end
    end
  end

  describe "SHOW" do 
    def send_request
      get :show, id: asset.id.to_s, asset_type_id: asset_type.id
    end

    it_should 'call before_action :find_unscoped_asset'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:show, asset)
      Asset.stub(:unscoped).and_return(@assets)
      @assets.stub(:where).with(company_id: company.id, id: asset.id.to_s).and_return(@assets)
      asset.stub(:comments).and_return(@comments)
      @comments.stub(:includes).with(:commenter).and_return(@comments)
      @comments.stub(:order).with("created_at desc").and_return(@comments)
      @comments.stub(:build).and_return(@comments)
      asset.stub(:asset_properties).and_return(@asset_properties)
      @asset_properties.stub(:includes).with(:property).and_return(@asset_properties)
    end

    describe "should_receive methods" do 
      
      it "asset should_receive comments" do 
        asset.should_receive(:comments).twice.and_return(@comments)
      end

      it "@asset_properties should_receive includes" do 
        @comments.should_receive(:includes).with(:commenter).and_return(@comments)
      end

      it "should_receive order" do 
        @comments.should_receive(:order).with("created_at desc").and_return(@comments)
      end

      it "@comments should_receive build" do 
        @comments.should_receive(:build).and_return(@comments)
      end

      it "should_receive asset_properties" do 
        asset.should_receive(:asset_properties).and_return(@asset_properties)
      end

      it "should_receive includes" do 
        @asset_properties.should_receive(:includes).with(:property).and_return(@asset_properties)
      end

      after do 
        send_request
      end
    end

    describe "assigns varaibles" do 
      before do 
        send_request
      end

      it "should assign asset_properties" do 
        expect(assigns[:asset_properties]).to eq(@asset_properties)
      end

      it "should assign comments" do 
        expect(assigns[:comments]).to eq(@comments)
      end

      it "should assign comment" do 
        expect(assigns[:comment]).to eq(asset.comments.build)
      end

      it "should assigns asset" do 
        expect(assigns[:asset]).to eq(asset)
      end
    end

    context "html request" do 
      it "should render template show" do 
        send_request
        response.should render_template "show"
      end

      it "should not receive audits" do 
        asset.should_not_receive(:audits)
        send_request
      end
      
      it "audits should_not_receive includes" do 
        @audits.should_not_receive(:includes)
        send_request
      end

      it "asset should_not_receive asset_properties" do 
        @audits.should_not_receive(:order)
        send_request
      end

      it "should_not_receive where" do 
        Audited::Adapters::ActiveRecord::Audit.should_not_receive(:where)
        send_request
      end
    end
    
    context "xhr request" do 
      def send_request
        xhr :get, :show, id: asset.id, asset_type_id: asset_type.id, query: "history"
      end

      before do 
        asset.stub(:audits).and_return(@audits)
        @audits.stub(:includes).with(:admin).and_return(@audits)
        @audits.stub(:order).with('audits.created_at desc').and_return(@audits)
        asset.stub(:asset_properties).and_return(@asset_properties)
        Audited::Adapters::ActiveRecord::Audit.stub(:where).with(auditable_type: "AssetProperty", auditable_id: [asset_property.id]).and_return(@audits)
        @audits.stub(:includes).with(:associated).and_return(@audits)
        @audits.stub(:order).with('audits.created_at desc').and_return(@audits)
      end

      context "params[:query] is 'history'" do 
        describe "should_receive methods" do 

          it "asset should_receive audits" do 
            asset.should_receive(:audits).and_return(@audits)
          end

          it "audits should_receive includes" do 
            @audits.should_receive(:includes).with(:admin).and_return(@audits)
          end

          it "asset should_receive asset_properties" do 
            @audits.should_receive(:order).with('audits.created_at desc').and_return(@audits)
          end

          it "should_receive where" do 
            Audited::Adapters::ActiveRecord::Audit.should_receive(:where).with(auditable_type: "AssetProperty", auditable_id: [asset_property.id]).and_return(@audits)
          end

          it "asset should_receive asset_properties" do 
            asset.should_receive(:asset_properties).and_return(@asset_properties)
          end

          it "audits should_receive includes" do 
            @audits.should_receive(:includes).with(:associated).and_return(@audits)
          end

          it "should_receive order" do 
            @audits.should_receive(:order).with('audits.created_at desc').and_return(@audits)
          end

          after do 
            send_request
          end
        end

        describe "assign instance varaibles" do 
          before do 
            send_request
          end

          it "should assign audits" do 
            expect(assigns[:audits]).to eq(@audits)
          end

          it "should assign property audits" do 
            expect(assigns[:property_audits]).to eq(@audits)
          end
        end
      end

      context "params[:query] is not 'history'" do 
        it "should not receive audits" do 
          asset.should_not_receive(:audits)
        end
        
        it "audits should_not_receive includes" do 
          @audits.should_not_receive(:includes)
        end

        it "asset should_not_receive asset_properties" do 
          @audits.should_not_receive(:order)
        end

        it "should_not_receive where" do 
          Audited::Adapters::ActiveRecord::Audit.should_not_receive(:where)
        end

        after do 
          xhr :get, :show, id: asset.id, asset_type_id: asset_type.id
        end
      end

      it "should render_template show" do 
        send_request
        response.should render_template "show"
      end
    end
  end

  describe "EDIT" do 
    def send_request
      get :edit, id: asset.id, asset_type_id: asset_type.id
    end

    it_should "should_receive authorize_resource"
    it_should 'call before_action :find_asset'

    before do 
      should_authorize(:edit, asset)
      company.stub(:assets).and_return(@assets)
      @assets.stub(:where).with(id: asset.id.to_s).and_return(@assets)
      asset.stub(:asset_type).and_return(asset_type)
      asset.stub(:file_uploads).and_return(@file_uploads)
      @file_uploads.stub(:build).and_return(@file_uploads)
    end
    
    it "should_receive asset_type" do 
      asset.should_receive(:asset_type).and_return(asset_type)
      send_request
    end

    it "should assign instance varaibles asset_type" do 
      send_request
      expect(assigns[:asset_type]).to eq(asset_type)
    end

    it "should render template edit" do 
      send_request
      response.should render_template "edit"
    end

    it "should_receive file_uploads" do 
      asset.should_receive(:file_uploads).and_return(@file_uploads)
      send_request
    end

    it "should_receive build" do 
      @file_uploads.should_receive(:build).and_return(@file_uploads)
      send_request
    end

    it "should assign instance varaibles file_uploads" do 
      send_request
      expect(assigns[:file_uploads]).to eq(@file_uploads)
    end

  end
  
  describe "NEW" do 
    def send_request
      get :new
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:new, Asset)
      company.stub(:asset_types).and_return(@asset_types)
      @asset_types.stub(:where).with(id: asset_type.id.to_s).and_return(@asset_types)
      asset.stub(:file_uploads).and_return(@file_uploads)
      @file_uploads.stub(:build).and_return(@file_uploads)
      Asset.stub(:new).and_return(asset)
    end

    it "assigns a new asset as asset" do
      send_request
      expect(assigns[:asset]).to eq(asset)
    end

    it "should render_template new" do 
      send_request
      response.should render_template("new")
    end
    
    describe "should_receive methods" do 
      before do 
        Asset.stub(:new).and_return(asset)
      end

      it "Asset should_receive new" do 
        Asset.should_receive(:new).and_return(asset)
        send_request
      end

      it "should_receive file_uploads" do 
        asset.should_receive(:file_uploads).and_return(@file_uploads)
        send_request
      end

      it "should_receive build" do 
        @file_uploads.should_receive(:build).and_return(@file_uploads)
        send_request
      end
    end

    it "should assigns instance varaible file_upload" do 
      send_request
      expect(assigns[:file_uploads]).to eq(@file_uploads)
    end

    context "params[:asset_type_id] is present" do 
      def send_request
        get :new, asset_type_id: asset_type.id.to_s
      end

      it "should_receive asset_types" do 
        controller.should_receive(:find_asset_type)
        send_request
      end

      it_should 'call method :find_asset_type'

    end

    context "params[:asset_type_id] is not present" do 

      it "should_not_receive asset_types" do 
        controller.should_not_receive(:find_asset_type)
        send_request
      end
    end

  end

  describe "CREATE" do 
    def send_request
      post :create, :asset => @valid_attributes
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:create, Asset)
      controller.stub(:params_asset).and_return(@valid_attributes)
      company.stub(:assets).and_return(@assets)
      @assets.stub(:build).with(@valid_attributes).and_return(asset)
      company.stub(:asset_types).and_return(@asset_types)
      @asset_types.stub(:where).with(id: asset_type.id.to_s).and_return(@asset_types)
      asset.stub(:file_uploads).and_return(@file_uploads)
      @file_uploads.stub(:build).and_return(@file_uploads)
    end
    
    context "asset created" do 
      before do
        Asset.any_instance.stub(:create_barcode).and_return(true) 
        send_request
      end
      
      it "flash should be present" do 
        flash[:notice].should eq("#{asset.name} has been created successfully")
      end

      it "should redirect_to show" do 
        response.should redirect_to [asset.asset_type, asset]
      end

      it "assigns a newly created asset as Asset" do
        assigns(:asset).should be_a(Asset)
      end

      it "should be persisted" do 
        assigns(:asset).should be_persisted
      end
    end

    context "asset not created" do 
      before do 
        asset.stub(:save).and_return(false)
      end 

      it "should render template new" do 
        send_request
        response.should render_template 'new'
      end

      it "flash should not be present" do 
        send_request
        flash[:notice].should_not eq("#{asset.name} has been created successfully")
      end

      context "params[:asset_type_id] not present" do 
        it "should_not_receive find_asset_type" do 
          controller.should_not_receive(:find_asset_type)
          send_request
        end
      end

      context "params[:asset_type_id] present" do 
        def send_request
          post :create, :asset => @valid_attributes, asset_type_id: asset_type.id.to_s
        end
        
        it "should_receive find_asset_type" do 
          controller.should_receive(:find_asset_type)
          send_request
        end

        it_should 'call method :find_asset_type'

      end

      context "file_uploads present" do 
        before do 
          @file_uploads.stub(:blank?).and_return(false)
        end

        it "should_not_receive build" do 
          @file_uploads.should_not_receive(:build)
          send_request
        end
      end

      context "file_uploads not present" do 
        before do 
          @file_uploads.stub(:blank?).and_return(true)
        end

        it "should assign instance varaibles asset_type" do 
          send_request
          expect(assigns[:file_uploads]).to eq(@file_uploads)
        end

        it "should_receive file_uploads" do 
          asset.should_receive(:file_uploads).and_return(@file_uploads)
          send_request
        end

        it "should_receive build" do 
          @file_uploads.should_receive(:build).and_return(@file_uploads)
          send_request
        end
      end
    end

    describe "should_receive methods" do 
      before do 
        asset.stub(:save).and_return(true)
      end

      it "should_receive params_asset" do 
        controller.should_receive(:params_asset).and_return(@valid_attributes)
      end

      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive assets" do 
        company.should_receive(:assets).and_return(@assets)
      end

      it "should_receive build" do 
        @assets.should_receive(:build).with(@valid_attributes).and_return(asset)
      end

      it "should_receive save" do 
        asset.should_receive(:save).and_return(true)
      end
      
      after do 
        send_request
      end
    end
  end

  describe "UPDATE" do 
    def send_request
      put :update, id: asset.id, asset: {name: "Demo Test"}, asset_type_id: asset_type.id
    end

    def send_xhr_request
      xhr :put, :update, id: asset.id, asset: {name: "Demo Test"}, asset_type_id: asset_type.id
    end

    it_should 'call before_action :find_asset'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:update, asset)
      company.stub(:assets).and_return(@assets)
      @assets.stub(:where).with(id: asset.id.to_s).and_return(@assets)
      controller.stub(:params_asset).and_return(@valid_attributes)
      asset.stub(:update_attributes).with(@valid_attributes).and_return(true)
      company.stub(:assets).and_return(@assets)
      @assets.stub(:where).with(id: asset.id.to_s).and_return([asset])
      asset.stub(:asset_type).and_return(asset_type)
      asset.stub(:file_uploads).and_return(@file_uploads)
      @file_uploads.stub(:build).and_return(@file_uploads)
    end

    context "assets are present" do 
      it "should_receive params_asset" do
        controller.should_receive(:params_asset).and_return(@valid_attributes)
      end

      it "should_receive update_attributes" do 
        asset.should_receive(:update_attributes).with(@valid_attributes).and_return(true)
      end

      after do 
        send_request
      end
    end
    
    context "updated" do 
      before do 
        send_request
      end

      it "should_receive file_uploads" do 
        asset.should_receive(:file_uploads).and_return(@file_uploads)
        send_request
      end

      it "should_receive build" do 
        @file_uploads.should_receive(:build).and_return(@file_uploads)
        send_request
      end

      context "xhr request" do 
        it "should have a flash notice" do 
          send_xhr_request
          flash[:notice].should eq("File uploaded successfully")
        end

        it "should render_template update" do 
          send_xhr_request
          response.should render_template "update"
        end
      end

      context "html request" do 
        it "should redirect_to show" do 
          response.should redirect_to [asset.asset_type, asset]
        end

        it "should have flash" do 
          flash[:notice].should eq("#{asset.name} has been updated successfully")
        end
      end
    end

    context "Update fail" do 
      before do 
        asset.stub(:update_attributes).with(@valid_attributes).and_return(false)
      end
      context "html request" do 
        it "should render_template edit" do 
          send_request
          response.should render_template "edit"
        end

        it "should_receive asset_type" do 
          asset.should_receive(:asset_type).and_return(asset_type)
          send_request
        end

        it "should assigns instance varaibles" do 
          send_request
          expect(assigns[:asset_type]).to eq(asset_type)
        end

        context "file_uploads present" do 
          before do 
            @file_uploads.stub(:blank?).and_return(false)
          end

          it "should_not_receive build" do 
            @file_uploads.should_not_receive(:build)
            send_request
          end
        end

        context "file_uploads not present" do 
          before do 
            @file_uploads.stub(:blank?).and_return(true)
          end

          it "should assign instance varaibles asset_type" do 
            send_request
            expect(assigns[:file_uploads]).to eq(@file_uploads)
          end

          it "should_receive file_uploads" do 
            asset.should_receive(:file_uploads).and_return(@file_uploads)
            send_request
          end

          it "should_receive build" do 
            @file_uploads.should_receive(:build).and_return(@file_uploads)
            send_request
          end
        end
      end

      context "xhr request" do 

        it "should_not_receive asset_type" do 
          asset.should_not_receive(:asset_type)
          send_xhr_request
        end

        it "should_not_receive file_uploads" do 
          asset.should_not_receive(:file_uploads)
          send_xhr_request
        end
      end
    end
  end

  describe "retire_asset" do 
    def send_request
      get :retire_asset, id: asset.id, asset_type_id: asset_type.id
    end
    
    it_should 'call before_action :find_asset'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:retire_asset, asset)
      @time = Time.now
      company.stub(:assets).and_return(@assets)
      @assets.stub(:where).with(id: asset.id.to_s).and_return(@assets)
      asset.stub(:update_attribute).and_return(true)
      asset.stub(:can_retire?).and_return(true)
    end

    context "asset can not retire" do 
      before do 
        asset.stub(:can_retire?).and_return(false)
        request.env["HTTP_REFERER"] = assets_path
      end

      it "should redirect to back" do 
        send_request
        response.should redirect_to assets_path
      end

      it "should not have flash" do 
        send_request
        flash[:alert].should eq("Asset is assigned, first return then retire it")
      end
    end

    context "asset can_retire" do 
      before do 
        asset.stub(:can_retire?).and_return(true)
      end

      context "asset not retired" do 
        before do 
          asset.stub(:update_attribute).and_return(false)  
        end
        
        it "should redirect_to assets_path" do 
          send_request
          response.should redirect_to [asset.asset_type, asset]
        end

        it "should have flash notice" do 
          send_request
          flash[:alert].should eq("There is some problem, Please contact support")
        end
      end

      context "asset retired" do 
        it "should redirect_to assets_path" do 
          send_request
          response.should redirect_to [asset.asset_type, asset]
        end

        it "should have flash notice" do 
          send_request
          flash[:notice].should eq("#{asset.name} has been retired successfully")
        end
      end

      describe "should_receive methods" do 

        it "should_receive update_attributes" do 
          asset.should_receive(:update_attribute).and_return(true)
          send_request
        end
      end
    end
  end
  
  describe "remove_tag" do 
    def send_request
      xhr :delete, :remove_tag, id: asset.id, tag_id: @tag.id, asset_type_id: asset_type.id
    end
    
    it_should 'call before_action :find_asset'
    it_should "should_receive authorize_resource"

    before do
      should_authorize(:remove_tag, asset)
      company.stub(:assets).and_return(@assets)
      @assets.stub(:where).with(id: asset.id.to_s).and_return(@assets)
      Tag.stub(:where).with(id: @tag.id.to_s).and_return([@tag])
      asset.stub(:remove_tags).with(@tag.id).and_return(true)
    end
    
    describe "should_receive methods" do 
      
      it "Tag should_receive where" do 
        Tag.should_receive(:where).with(id: @tag.id.to_s).and_return([@tag])
      end
      
      it "should_receive remove_tags" do 
        asset.should_receive(:remove_tags).with(@tag.id).and_return(true)
      end
      after do 
        send_request
      end
    end

    it "should render_template remove_tag" do 
      send_request
      response.should render_template "assets/remove_tag"
    end

    describe "should assign instance varaibles" do 
      before do 
        send_request
      end

      it "should assign asset" do 
        expect(assigns[:asset]).to eq(asset)
      end

      it "should assign tag" do 
        expect(assigns[:tag]).to eq(@tag)
      end
    end
    
    context "tag deleted" do 
      it "flash[:notice] should display" do 
        send_request
        flash[:notice].should eq("Tag #{@tag.name} has been removed successfully")
      end
    end

    context "tag not deleted" do 
      
      context "tag not present" do 
        before do 
          Tag.stub(:where).with(id: @tag.id.to_s).and_return([])
        end

        it "flash[:alert] should be present" do 
          send_request
          flash[:alert].should eq("Tag could not be removed")
        end

        it "should not have flash[:notice]" do 
          send_request
          flash[:notice].should_not eq("Tag #{@tag.name} has been removed successfully")
        end
      end

      context "tag present but remove_tags return false" do 
        before do 
          asset.stub(:remove_tags).with(@tag.id).and_return(false)
        end

        it "flash[:alert] should be present" do 
          send_request
          flash[:alert].should eq("Tag could not be removed")
        end

        it "should not have flash[:notice]" do 
          send_request
          flash[:notice].should_not eq("Tag #{@tag.name} has been removed successfully")
        end
      end
    end
  end

  describe "get_autocomplete_items" do 
    before do 
      should_authorize(:get_autocomplete_items, Asset)
      @parameters = {:model=>Asset, :options=>{:full=>true, :limit=>1000}, :term=>"te", :method=>:name}
      Asset.any_instance.stub(:create_barcode).and_return(true)
      @asset = Asset.create!("asset_type_id"=>asset_type.id, "name"=>"Demo asset", "status"=>"spare", "brand"=> "Dell", "currency_unit"=>"&#8377;", "cost"=>"100.0", "serial_number"=>"YUIYssIU78sdf789IU", "vendor"=>"CNC", "purchase_date"=>"29/09/2011", "description"=>"Test Desc", "additional_info"=>"Test ADD Info","company_id"=>1)
    end

    def send_request
      xhr :get, :autocomplete_asset_name, term: 'test'
    end
    
    context "assets from current_company" do 
      context "search term is name"  do 
        before do  
          @parameters1 = {:model=>Asset, :options=>{:full=>true, :limit=>1000}, :term=>"Demo", :method=>:name}
          @result = Asset.select(:id, :name).where(name: "Demo asset")
        end
        it "should return assets having search term in name" do 
          controller.get_autocomplete_items(@parameters1).first.should eq(@result.first)
        end
      end

      context "search term is vendor" do 
        before do 
          @parameters2 = {:model=>Asset, :options=>{:full=>true, :limit=>1000}, :term=>"CNC", :method=>:vendor}
          @vendor = Asset.select(:id, :vendor).where(vendor: "CNC")
        end
        it "should return assets having search term in vendor" do 
          controller.get_autocomplete_items(@parameters2).first.should eq(@vendor.first)
        end
      end

      context "search term is brand" do 
        before do 
          @parameters3 = {:model=>Asset, :options=>{:full=>true, :limit=>1000}, :term=>"Dell", :method=>:brand}
          @brand = Asset.select(:id, :brand).where(brand: "Dell")
        end
        it "should return assets having search term in brand" do 
          controller.get_autocomplete_items(@parameters3).first.should eq(@brand.first)
        end
      end
    end

    context "assets not from current_company" do 
      before do 
        @asset = Asset.create!("asset_type_id"=>asset_type.id, "name"=>"company2", "status"=>"spare", "brand"=> "comp2", "currency_unit"=>"&#8377;", "cost"=>"100.0", "serial_number"=>"YUIYsddsIU78sdf789IU", "vendor"=>"CNC", "purchase_date"=>"29/09/2011", "description"=>"Test Desc", "additional_info"=>"Test ADD Info","company_id"=>2)
      end
      context "search term is name"  do 
        before do  
          @parameters4 = {:model=>Asset, :options=>{:full=>true, :limit=>1000}, :term=>"company2", :method=>:name}
        end
        it "should return blank result" do 
          controller.get_autocomplete_items(@parameters4).should eq([])
        end
      end
    end
  end

  describe "params_asset" do 
    before do 
      should_authorize(:update, asset)
      company.stub(:assets).and_return(@assets)
      @assets.stub(:where).with(id: asset.id.to_s).and_return(@assets)
      asset.stub(:update_attributes).and_return(true)
      asset.stub(:file_uploads).and_return(@file_uploads)
      @file_uploads.stub(:build).and_return(@file_uploads)
    end

    context "with permitted parameter" do 

      it "should_receive permit" do 
        asset.should_receive(:update_attributes).with({"name"=>"Demo"})
      end

      after do
        put :update, id: asset.id, asset: {name: "Demo"}, asset_type_id: asset_type.id
      end
    end

    context "with unpermitted parameter" do 
      it "should_receive permit" do 
        asset.should_receive(:update_attributes).with({"name"=>"Demo"})
      end
      
      it "should_not_receive permit with unpermitted data" do 
        asset.should_not_receive(:update_attributes).with({"name"=>"Demo","created_at"=>Time.now})
      end

      after do
        put :update, id: asset.id, asset: {name: "Demo", created_at: Time.now}, asset_type_id: asset_type.id
      end
    end
  end

  describe "autocomplete" do 

    it "should define autocomplete method for tag name" do 
      AssetsController.method_defined?(:autocomplete_tag_name).should be_true
    end

    it "should define autocomplete method for asset brand" do 
      AssetsController.method_defined?(:autocomplete_asset_brand).should be_true
    end

    it "should define autocomplete method for asset vendor" do 
      AssetsController.method_defined?(:autocomplete_asset_vendor).should be_true
    end
  end

  describe "uploaded_files" do 
    def send_request
      xhr :put, :uploaded_files, id: asset.id
    end 

    it_should 'call before_action :find_unscoped_asset'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:uploaded_files, asset)
      Asset.stub(:unscoped).and_return(@assets)
      @assets.stub(:where).with(company_id: company.id, id: asset.id.to_s).and_return(@assets)
      asset.stub(:asset_type).and_return(asset_type)
      asset.stub(:file_uploads).and_return(@file_uploads)
      @file_uploads.stub(:build).and_return(@file_uploads)
    end

    it "should render_template uploaded_files" do 
      send_request
      response.should render_template "uploaded_files"
    end

    it "should assigns instance varaibles" do 
      send_request
      expect(assigns[:file_uploads]).to eq(@file_uploads)
    end

    it "should_receive file_uploads" do 
      asset.stub(:file_uploads).and_return(@file_uploads)
      send_request
    end

    it "should_receive build" do 
      @file_uploads.stub(:build).and_return(@file_uploads)
      send_request
    end

  end

  describe "#tickets" do 
    def send_request
      xhr :get, :tickets, id: asset.id, page: "1"
    end 

    it_should 'call before_action :find_unscoped_asset'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:tickets, asset)
      Asset.stub(:unscoped).and_return(@assets)
      @assets.stub(:where).with(company_id: company.id, id: asset.id.to_s).and_return(@assets)
      asset.stub(:tickets).and_return(@tickets)
      @tickets.stub(:order).with('tickets.created_at desc').and_return(@tickets)
      @tickets.stub(:includes).with(:ticket_type, :employee, :asset).and_return(@tickets)
      @tickets.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@tickets)
    end

    it "should_receive tickets" do 
      asset.should_receive(:tickets).and_return(@tickets)
      send_request
    end

    it "should_receive includes" do 
      @tickets.should_receive(:includes).with(:ticket_type, :employee, :asset).and_return(@tickets)
      send_request
    end

    it "should_receive order" do 
      @tickets.should_receive(:order).with('tickets.created_at desc').and_return(@tickets)
      send_request
    end

    it "should_receive paginate" do 
      @tickets.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@tickets)
      send_request
    end

    it "should assigns instance varaibles" do 
      send_request
      expect(assigns[:tickets]).to eq(@tickets)
    end

    it "should render_template tickets" do 
      send_request
      response.should render_template "tickets"
    end
  end
  
  describe "#autocomplete_assets_name" do 
    def send_request
      xhr :get, :autocomplete_assets_name, query: asset.serial_number
    end 

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:autocomplete_assets_name, Asset)
      @serach_result = {value: "#{asset.name} (S.N. #{asset.serial_number})"}
      Asset.stub(:select).with([:name, :serial_number]).and_return(@assets)
      @assets.stub(:where).with("(name LIKE ? OR serial_number like ?) AND company_id = ?", "%#{asset.serial_number}%", "%#{asset.serial_number}%", company.id).and_return(@serach_result)
      @serach_result.stub(:collect).and_return(@serach_result.to_json)
    end

    it "should_receive select" do 
      Asset.should_receive(:select).with([:name, :serial_number]).and_return(@assets)
      send_request
    end

    it "should_receive where" do 
      @assets.should_receive(:where).with("(name LIKE ? OR serial_number like ?) AND company_id = ?", "%#{asset.serial_number}%", "%#{asset.serial_number}%", company.id).and_return(@serach_result)
      send_request
    end

    it "should_receive collect" do 
      @serach_result.should_receive(:collect)
      send_request
    end

    it "should return serach_result" do 
      send_request
      response.body.should eq(@serach_result.to_json)
    end
  end

end