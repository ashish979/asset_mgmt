require 'spec_helper'
include ControllerHelper

describe AssignmentsController do

  shared_examples_for 'call before_action :find_assinable_assets' do

    describe "should_receive methods" do 

      it "controller should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company should_receive asset" do 
        company.should_receive(:assets).and_return(@assets)
      end

      it "assets should_receive where" do 
        @assets.should_receive(:assignable).and_return(@assets)
      end

      after do 
        send_request
      end
    end

    it "should assigns instance variable assets" do 
      send_request
      expect(assigns[:assets]).to eq(@assets)
    end
  end

  shared_examples_for 'call before_action :find_assignment' do

    describe "should_receive methods" do 

      it "should_receive where" do 
        Assignment.should_receive(:where).with(id: assignment.id.to_s).and_return(@assignments)
      end

      after do 
        send_request
      end
    end

    it "should assigns instance variable assets" do 
      send_request
      expect(assigns[:assignment]).to eq(assignment)
    end

    context "assignment not found" do 
      before do 
        Assignment.stub(:where).with(id: assignment.id.to_s).and_return([])
        request.env["HTTP_REFERER"] = root_path
        send_request
      end

      it "should have a flash alert" do 
        flash[:alert].should eq("Assignment not found for specified id")
      end

      it "should redirect_to root_path" do 
        response.should redirect_to root_path
      end
    end

    context "assignment found" do 

      it "should not have a flash alert" do 
        send_request
        flash[:alert].should_not eq("Assignment not found for specified id")
      end
    end
  end

  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com") }
  let(:assignment) { mock_model(Assignment, :save => true, :employee_id => employee.id, :asset_id => asset.id, :date_returned => DateTime.now) }
  let(:comment) { mock_model(Comment, :resource_id => asset.id)}
  let(:asset_type) { mock_model(AssetType, :svae => true, id: 1, name: "laptop", company_id: company.id)}
  let(:asset)  { mock_model(Asset, :save => true, "id"=>1,"asset_type_id"=>asset_type.id,"name"=>"Test Name", "status"=>"spare", "currency_unit"=>"&#8377;", "cost"=>"100.0", "serial_number"=>"YUIYIU78sdf789IU", "vendor"=>"Test", "purchase_date"=>"29/09/2011", "resource_attributes"=>{"operating_system"=>"TEST OS", "has_bag"=>"false"}, "description"=>"Test Desc", "additional_info"=>"Test ADD Info", "barcode"=>"0001000001") }
  let(:mail_object) { double(Mail::Message) }

  before do
    @admin = employee
    @valid_attributes = {:employee_id => employee.id, :asset_id => asset.id, :date_issued => DateTime.now - 1}
    @assignments = [assignment]
    @assets = [asset]
    @employees = [employee]
    @comments = [comment]
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    controller.stub(:logout_if_disable).and_return(true)
    controller.stub(:verify_current_company)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
    AssignmentNotifier.stub(:assignment_notification).and_return(mail_object)
    mail_object.stub(:deliver)
  end

  describe "CREATE" do
    def send_request
      post :create, :assignment => @valid_attributes
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:create, Assignment)
      controller.stub(:assignment_params).and_return(@valid_attributes)
      Assignment.stub(:new).with(@valid_attributes).and_return(assignment)
      assignment.stub(:add_commenter).with(employee).and_return(assignment)
      assignment.stub(:employee).and_return(employee)
      assignment.stub(:asset).and_return(asset)
    end
    
    it "should assigns instance variable assignment" do 
      send_request
      expect(assigns[:assignment]).to eq(assignment)
    end

    describe "should_receive methods" do 

      it "should_receive assignment_params" do 
        controller.should_receive(:assignment_params).and_return(@valid_attributes)
      end

      it "should_receive new" do 
        Assignment.should_receive(:new).with(@valid_attributes).and_return(assignment)
      end

      it "should_receive add_commenter" do 
        assignment.should_receive(:add_commenter).and_return(assignment)
      end

      it "should_receive save" do 
        assignment.should_receive(:save).and_return(true)
      end

      after do 
        send_request
      end
    end

    context "created successfully" do 
      it "assigns a newly created assignment as assignment" do
        send_request
        assigns(:assignment).should be_a(Assignment)
      end

      it "should be persisted" do 
        send_request
        assigns(:assignment).should be_persisted
      end

      it "should redirect_to show of employee" do 
        send_request
        response.should redirect_to(assignment.employee)
      end

      it "should have flash notice" do 
        send_request
        flash[:notice].should eq("#{assignment.asset.try(:name)} has been successfully assigned to #{assignment.employee.try(:name)}")
      end

      it "should_receive employee" do 
        assignment.should_receive(:employee).and_return(employee)
        send_request
      end
    end

    context "not created" do 
      before do 
        assignment.stub(:save).and_return(false)
        assignment.stub(:comments).and_return(@comments)
        @comments.stub(:build).and_return(comment)
      end

      it "should render template new" do 
        send_request
        response.should render_template 'new'
      end

      it "should_receive comments" do
        assignment.should_receive(:comments).and_return(@comments)
        send_request
      end
      
      context "comments present" do 
        it "should_not_receive build" do 
          @comments.should_not_receive(:build)
          send_request
        end
      end

      context "comments not present" do 
        before do
          @comments.stub(:blank?).and_return(true)
        end
        it "should_receive build" do 
          @comments.should_receive(:build).and_return(comment)
          send_request
        end
      end
    end
  end

  describe "NEW" do 
    def send_request
      get :new
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:new, Assignment)
      Assignment.stub(:new).and_return(assignment)
      assignment.stub(:comments).and_return(@comments)
      @comments.stub(:build).and_return(comment)
    end

    it "should render_template new" do 
      send_request
      response.should render_template("new")
    end

    it "should assign assignment" do 
      send_request
      expect(assigns[:assignment]).to eq(Assignment.new)
    end

    describe "should_receive methods" do 
      it "should_receive new" do 
        Assignment.should_receive(:new).and_return(assignment)
        send_request
      end

      it "should_receive comments" do 
        assignment.should_receive(:comments).and_return(@comments)
        send_request
      end

      it "should_receive build" do 
        @comments.should_receive(:build).and_return(comment)
        send_request
      end
    end
      
    context "params[:asset_type_id] present" do 
      def send_request
        get :new, asset_id: asset.id, asset_type_id: asset_type.id
      end

      before do 
        AssetType.stub(:where).with(id: asset_type.id.to_s).and_return([asset_type])
        Asset.stub(:where).with(id: asset.id.to_s).and_return([asset])
      end
      
      describe "should_receive methods" do 

        it "should_receive where" do 
          Asset.should_receive(:where).with(id: asset.id.to_s).and_return([asset])
        end

        it "should_receive asset_type" do 
          AssetType.should_receive(:where).with(id: asset_type.id.to_s).and_return([asset_type])
        end

        after do 
          send_request
        end
      end
      
      describe "assigns instance variable" do
        before do 
          send_request
        end

        it "should assign asset type" do 
          expect(assigns[:asset_type]).to eq(asset_type)
        end

        it "should assign asset" do 
          expect(assigns[:asset]).to eq(asset)
        end
      end
    end

    context "params[:asset_type_id] not present" do 
      it "should_not_receive where" do 
        Asset.should_not_receive(:where)
      end

      it "should_not_receive asset_type" do 
        AssetType.should_not_receive(:where)
      end

      after do 
        send_request
      end
    end
  end

  describe "return_asset" do 
    def send_request
      get :return_asset, id: asset.id.to_s, type: "asset"
    end

    it_should "should_receive authorize_resource"
    
    before do 
      should_authorize(:return_asset, Assignment)
      Assignment.stub(:where).with(asset_id: asset.id.to_s).and_return(@assets)
      @assets.stub(:assigned_assets).and_return(@assignments)
      @assignments.stub(:includes).with(:asset, :comments).and_return(@assignments)
      assignment.stub(:comments).and_return(@comments)
      @comments.stub(:build).and_return(comment)
    end

    it "should render_template return_asset" do 
      send_request
      response.should render_template "return_asset"
    end

    it "should assign instance variable asignment" do 
      send_request
      expect(assigns[:assignment]).to eq(assignment)
    end

    describe "should_receive methods" do 

      it "Assignment should receive where" do 
        Assignment.should_receive(:where).with(asset_id: asset.id.to_s).and_return(@assets)
      end

      it "@employees should receive assigned_assets" do 
        @assets.should_receive(:assigned_assets).and_return(@assignments)
      end

      it "@assignments should receive includes" do 
        @assignments.should_receive(:includes).with(:asset, :comments).and_return(@assignments)
      end
      
      after do 
        send_request
      end
    end
      
    context "assignment is present" do 
      before do 
        assignment.stub(:blank?).and_return(false)
        assignment.stub(:comments).and_return(@comments)
      end

      it "should receive comment" do 
        assignment.should_receive(:comments)
      end

      it "comment receive build" do 
        @comments.should_receive(:build).and_return(comment)
      end

      after do
        send_request
      end
    end

    context "assignment is blank" do 
      before do 
        assignment.stub(:blank?).and_return(true)
        send_request
      end

      it "should redirect to assets_path" do 
        response.should redirect_to assets_path
      end

      it "should have flash alert" do 
        flash[:alert].should eq("No asset is assigned to selected pair")
      end
    end
  end

  describe "UPDATE" do 
    def send_request
      put :update, id: assignment.id.to_s, assignment: {asset_id: asset.id.to_s}
    end
    
    it_should 'call before_action :find_assignment'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:update, assignment)
      Assignment.stub(:where).with(id: assignment.id.to_s).and_return(@assignments)
      controller.stub(:assignment_params).and_return(@valid_attributes)
      assignment.stub(:attributes=).and_return(assignment)
      assignment.stub(:add_commenter).with(employee).and_return(assignment)
      assignment.stub(:update_attributes).with(@valid_attributes).and_return(true)
      assignment.stub(:employee).and_return(employee)
      assignment.stub(:asset).and_return(asset)
    end

    describe "should_receive methods" do 
  
      it "should_receive assignment_params" do 
        controller.should_receive(:assignment_params).and_return(@valid_attributes)
      end

      it "should_receive attributes=" do 
        assignment.should_receive(:attributes=).and_return(assignment)
      end

      it "should_receive add_commenter" do 
        assignment.should_receive(:add_commenter).and_return(assignment)
      end

      it "should_receive save" do 
        assignment.should_receive(:save).and_return(true)
      end

      after do 
        send_request
      end
    end

    context "updated successfully" do 
      it "should redirect_to show" do
        send_request 
        response.should redirect_to employee_path(assignment.employee)
      end

      it "should have a flash" do 
        send_request
        flash[:notice].should eq("#{assignment.asset.try(:name)} has been returned successfully")
      end

      it "should_receive employee" do 
        assignment.should_receive(:employee).and_return(employee)
        send_request
      end
    end

    context "Update fail" do 
      before do 
        assignment.stub(:save).and_return(false)
        assignment.stub(:comments).and_return(@comments)
        @comments.stub(:build).and_return(comment)
      end

      it "should render_template return_asset" do 
        send_request
        response.should render_template "return_asset"
      end
      
      context "comments blank" do 
        before do 
          @blank_comment = []
          assignment.stub(:comments).and_return(@blank_comment)
          @blank_comment.stub(:build).and_return(comment)
        end

        it "should_receive comments" do 
          assignment.should_receive(:comments).twice.and_return(@blank_comment)
          send_request
        end

        it "should_receive build" do 
          @blank_comment.should_receive(:build).and_return(comment)
          send_request
        end
      end

      context "comments present" do 
        before do 
          assignment.stub(:comments).and_return(@comments)
        end

        it "should_not_receive comments" do 
          assignment.should_receive(:comments).once
          send_request
        end

        it "should_not_receive build" do 
          @comments.should_not_receive(:build)
          send_request
        end
      end
    end
  end

  describe "change_aem_form" do 
    before do 
      should_authorize(:change_aem_form, Assignment)
      company.stub(:assets).and_return(@assets)
    end

    context "params[:barcode] present" do 
      def send_request
        xhr :get, :change_aem_form, barcode: asset.barcode  
      end

      it_should 'call before_action :find_assinable_assets'
      it_should "should_receive authorize_resource"

      before do 
        @assets.stub(:assignable).and_return(@assets)
        @assets.stub(:where).with(barcode: asset.barcode).and_return(@assets)
        asset.stub(:asset_type_id).and_return(asset_type.id.to_s)
        @assets.stub(:where).with(asset_type_id: asset_type.id.to_s).and_return(@assets)
      end

      it "should assigns asset" do 
        send_request
        expect(assigns[:asset]).to eq(asset)
      end

      it "@assets should_receive where" do 
        @assets.should_receive(:where).with(barcode: asset.barcode).and_return(@assets)
        send_request
      end

      it "should render_template change_aem_form" do 
        send_request
        response.should render_template "change_aem_form"
      end

      context "asset not found" do 
        before do 
          @assets.stub(:first).and_return(nil)
        end

        it "should have flash alert" do 
          send_request
          flash[:alert].should eq("There is no spare asset with barcode: 0001000001")
        end
      end

      context "asset found" do 

        it "should not have flash" do 
          send_request
          flash[:alert].should_not eq("There is no spare asset with barcode: 0001000001")
        end

        it "should_receive where" do
          @assets.should_receive(:where).with(asset_type_id: asset_type.id.to_s).and_return(@assets)
          send_request
        end
      end
    end
    
    context "params[:barcode] not present" do

      def send_request
        xhr :get, :change_aem_form, asset: asset.id.to_s
      end

      before do 
        @assets.stub(:where).with(id: asset.id.to_s).and_return(@assets)
        asset.stub(:asset_type_id).and_return(asset_type.id)
      end

      describe "should_receive methods" do 

        it "should_receive company" do 
          controller.should_receive(:current_company).and_return(company)
        end

        it "company should_receive assets" do 
          company.should_receive(:assets).and_return(@assets)
        end

        it "assets should_receive where" do 
          @assets.should_receive(:where).with(id: asset.id.to_s).and_return(@assets)
        end

        it "should_receive asset_type_id" do 
          asset.should_receive(:asset_type_id).and_return(asset_type.id)
        end

        after do 
          send_request
        end
      end

      it "should assign instance variable asset_type" do 
        send_request
        expect(assigns[:asset_type]).to eq(asset_type.id)
      end

      it "should render_template change_aem_form" do 
        send_request
        response.should render_template "change_aem_form"
      end
    end
  end

  describe "populate_asset" do 
    def send_request
      xhr :get, :populate_asset, category: asset_type.id.to_s
    end

    it_should 'call before_action :find_assinable_assets'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:populate_asset, Assignment)
      company.stub(:assets).and_return(@assets)
      @assets.stub(:assignable).and_return(@assets)
      @assets.stub(:where).with(asset_type_id: asset_type.id.to_s).and_return(@assets)
    end

    it "should render_template populate_asset" do 
      send_request
      response.should render_template "populate_asset"
    end

    context "params[:category] present" do 

      it "@assets should_receive where" do 
        @assets.should_receive(:where).with(asset_type_id: asset_type.id.to_s).and_return(@assets)
        send_request
      end

      it "should assigns instance variable assets" do
        send_request
        expect(assigns[:assets]).to eq(@assets)
      end
    end

    context "params[:category] is blank" do 
      def send_request
        xhr :get, :populate_asset, category: ""
      end
      
      it "assets should_not_receive where" do 
        @assets.should_not_receive(:where)
      end
    end
  end
  
  describe "assignment_params" do 
    def send_request
      post :create, :assignment => {:employee_id => employee.id, :asset_id => asset.id}
    end

    before do 
      should_authorize(:create, Assignment)
      Assignment.stub(:new).and_return(assignment)
      assignment.stub(:add_commenter).with(employee).and_return(assignment)
      assignment.stub(:employee).and_return(employee)
      assignment.stub(:asset).and_return(asset)
      assignment.stub(:save).and_return(true)
    end

    context "with permitted parameter" do 

      it "should_receive permit" do 
        Assignment.should_receive(:new).with({"asset_id"=>"1", "employee_id"=>employee.id.to_s})
      end

      after do
        send_request
      end
    end

    context "with unpermitted parameter" do 
      it "should_receive permit" do 
        Assignment.should_receive(:new).with({"asset_id"=>"1", "employee_id"=>employee.id.to_s})
      end
      
      it "should_not_receive permit with unpermitted data" do 
        Assignment.should_not_receive(:new).with({"asset_id"=>"1", "employee_id"=>employee.id.to_s,"test"=>"test"})
      end

      after do
        post :create, :assignment => {:employee_id => employee.id, :asset_id => asset.id, :test=>"test"}
      end
    end

  end

end