require 'spec_helper'
include ControllerHelper

describe CommentsController do
  shared_examples_for "call before_action load_resource for comments" do 
    it "Comment should_receive find" do 
      Comment.should_receive(:find).and_return(@comment)
      send_request
    end

    context "record found" do 
      it "should assign instance variable" do 
        send_request
        expect(assigns[:comment]).to eq(@comment)
      end
    end

    context "record not found" do 
      before do 
        Comment.stub(:find).and_return(nil)
      end

      it "should raise exception" do 
        expect{ send_request }.to raise_exception
      end
    end
  end

  shared_examples_for "call before_action :find_resource" do 

    describe "should_receive methods" do 
      it "should_receive resource_class" do 
        controller.should_receive(:resource_class).and_return(Asset)        
      end

      it "should_receive unscoped" do 
        Asset.should_receive(:unscoped).and_return(Asset)
      end

      it "should_receive where" do 
        Asset.should_receive(:where).with(id: @asset.id.to_s, company_id: company.id).and_return(@assets)
      end

      after do 
        send_request
      end
    end

    describe "assigns instance variable" do 
      before do
        send_request
      end

      it "should assigns instance variable" do 
        expect(assigns[:resource]).to eq(@asset)
      end
    end

  end

  let(:company) { mock_model(Company) }
  let(:aem) { mock_model(Assignment, :save => true, :employee_id => 4, :asset_id => 1, :date_returned => DateTime.now, :remark => "assign") }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com") }
  let(:asset_type)  { mock_model(AssetType, :save => true, "name"=>"laptop") }

  before do
    @admin = employee
    @aems = [aem]
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    controller.stub(:logout_if_disable).and_return(true)
    controller.stub(:verify_current_company)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
    Asset.any_instance.stub(:create_barcode).and_return(true)
    @asset = Asset.create!("name"=>"Test Name", "status"=>"spare","currency_unit"=>"&#8377;", "cost"=>"100.0", "serial_number"=>"YUIYIU78sdf789IUi", "brand"=>"HP", "vendor"=>"Test", "purchase_date"=>"29/09/2011", "description"=>"Test Desc", "additional_info"=>"Test ADD Info","asset_type_id"=> asset_type.id)
    @comment = Comment.create!("body"=>"laptop", "resource_id"=>@asset.id, "resource_type"=>"Asset")
    @comment.stub(:commenter_id=).and_return(employee.id)
    @assets = [@asset]
    @valid_attributes = {asset_id: @asset.id, body: "Test Comment"}
  end
    
  describe "CREATE" do 
    def send_request
      xhr :post, :create, comment: {resource_id: @asset.id, body: "Test Comment"}
    end
        
    it_should "should_receive authorize_resource"
    it_should "call before_action :find_resource"

    before do 
      should_authorize(:create, Comment)
      controller.stub(:params_comments).and_return(@valid_attributes)
      controller.stub(:resource_class).and_return(Asset)
      Asset.stub(:unscoped).and_return(Asset)
      Asset.stub(:where).with(id: @asset.id.to_s, company_id: company.id).and_return(@assets)
      controller.stub(:return_requester)
      @asset.stub(:comments).and_return(@comment)
      @comment.stub(:includes).with(:commenter).and_return(@comment)
      @comment.stub(:order).with("created_at desc").and_return(@comment)
      @comment.stub(:build).with(@valid_attributes).and_return(@comment)
      @comment.stub(:save).and_return(true)
    end
    
    describe "should_receive methods" do 

      it "asset should_receive comment" do 
        @asset.should_receive(:comments).and_return(@comment)
      end

      it "@comment should_receive build" do 
        @comment.should_receive(:build).with(@valid_attributes).and_return(@comment)
      end

      it "@comment should_receive save" do 
        @comment.should_receive(:save).and_return(true)
      end

      it "should_receive params_comments" do 
        controller.should_receive(:params_comments).and_return(@valid_attributes)
      end
      
      it "@comment should_receive commenter_id" do 
        @comment.should_receive(:commenter_id=).and_return(employee.id)
      end

      after do 
        send_request
      end
    end
    
    describe "asssigns instance variables" do 
      before do 
        send_request
      end

      it "should assigns asset" do 
        expect(assigns[:comment]).to eq(@comment)
      end
    end

    context "record created" do 
    
      it "flash message should present" do 
        send_request
        flash[:notice].should eq("Comment Added Successfully")
      end

      it "should assigns instance variable comments" do 
        send_request
        expect(assigns[:comments]).to eq(@comment)
      end

      it "should_receive comments twice" do 
        @asset.should_receive(:comments).twice
        send_request
      end
      
      it "should_receive includes" do 
        @comment.should_receive(:includes).with(:commenter).and_return(@comment)
        send_request
      end

      context "resource_class Ticket" do 
        before do 
          controller.stub(:resource_class).and_return(Ticket)
          Ticket.stub(:unscoped).and_return(Ticket)
          Ticket.stub(:where).with(id: @asset.id.to_s, company_id: company.id).and_return(@assets)
        end
        it "should_not_receive order" do 
          @comment.should_not_receive(:order)
          send_request
        end
      end

      context "resource_class not Ticket" do 
        before do 
          controller.stub(:resource_class).and_return(Asset)
        end

        it "should_receive order" do 
          @comment.should_receive(:order).with("created_at desc").and_return(@comment)
          send_request
        end
      end

    end

    context "record not created" do 
      before do 
        @comment.stub(:save).and_return(false)
      end
      
      it "flash message should not be present" do 
        send_request
        flash[:notice].should_not eq("Comment Added Successfully")
      end

      it "asset should_receive comment once" do 
        @asset.should_receive(:comments).once
        send_request
      end

      it "@comment should_not_receive includes" do 
        @comment.should_not_receive(:includes)
        send_request
      end
    end

    it "should render template create" do 
      send_request
      response.should render_template "create"
    end
   end

  describe "DESTROY" do 
    def send_request
      xhr :delete, :destroy, id: @comment.id.to_s, resource_class: "assets"
    end
    
    it_should "should_receive authorize_resource"
    it_should "call before_action load_resource for comments"

    before do 
      should_authorize(:destroy, @comment)
      controller.stub(:resource_class).and_return(Asset)
      Asset.stub(:unscoped).and_return(Asset)
      @comment.stub(:resource_id).and_return(@asset.id)
      Asset.stub(:where).with(id: @asset.id, company_id: company.id).and_return(@assets)
      @comment.stub(:destroy).and_return(true)
      @asset.stub(:comments).and_return(@comment)
      @comment.stub(:includes).with(:commenter).and_return(@comment)
      @comment.stub(:order).with("created_at desc").and_return(@comment)
      Comment.stub(:find).and_return(@comment)
    end    

    describe "should_receive methods" do 
      it "should_receive resource_class" do 
        controller.should_receive(:resource_class).and_return(Asset)
      end

      it "should_receive unscoped" do 
        Asset.should_receive(:unscoped).and_return(Asset)
      end

      it "should_receive resource_id" do 
        @comment.should_receive(:resource_id).and_return(@asset.id)
      end

      it "should_receive where" do 
        Asset.should_receive(:where).with(id: @asset.id, company_id: company.id).and_return(@assets)
      end

      it "should_receive destroy" do 
        @comment.should_receive(:destroy).and_return(true)
      end

      after do 
        send_request
      end
    end

    describe "assigns instance variable" do 
      before do 
        send_request
      end

      it "should assigns asset" do 
        expect(assigns[:resource]).to eq(@asset)
      end

      it "should assigns comment" do 
        expect(assigns[:comment]).to eq(@comment)
      end
    end

    context "record destroyed" do 
      before do 
        @comment.stub(:destroy).and_return(true)
        @asset.stub(:comments).and_return(@comment)
        @comment.stub(:includes).with(:commenter).and_return(@comment)
      end
      
      it "flash notice should be 'Comment Deleted Successfully'" do
        send_request
        flash[:notice].should eq('Comment Deleted Successfully')
      end

      it "asset should_receive @comment" do 
        @asset.should_receive(:comments).and_return(@comment)
        send_request
      end

      it "should_receive includes" do 
        @comment.should_receive(:includes).with(:commenter).and_return(@comment)
        send_request
      end

      it "should_receive order" do 
        @comment.should_receive(:order).with("created_at desc").and_return(@comment)
        send_request
      end

      it "should assigns instance variable" do 
        send_request
        expect(assigns[:comments]).to eq(@comment)
      end
    end

    context "record not destroyed" do 
      before do 
        @comment.stub(:destroy).and_return(false)
      end

      it "flash alert should present" do 
        xhr :delete, :destroy, id: @comment.id
        flash[:alert].should eq("Comment could not be deleted")
      end
    end

    it "should render_template destroy" do 
      send_request
      response.should render_template "destroy"
    end
  end 

  describe "params_comments" do 
    describe "should_receive methods" do 

      before do 
        should_authorize(:create, Comment)
        controller.stub(:resource_class).and_return(Asset)
        Asset.stub(:unscoped).and_return(Asset)
        Asset.stub(:where).with(id: @asset.id.to_s, company_id: company.id).and_return(@assets)
        @asset.stub(:comments).and_return(@comment)
        @comment.stub(:includes).with(:commenter).and_return(@comment)
        @comment.stub(:order).with("created_at desc").and_return(@comment)
        @comment.stub(:build).and_return(@comment)
        @comment.stub(:save).and_return(true)
      end

      context "with permitted parameter" do 

        it "should_receive permit" do 
          @comment.should_receive(:build).with({"resource_id"=>@asset.id.to_s})
        end

        after do
          xhr :post, :create, comment: {resource_id: @asset.id, comment: "Test Comment"}
        end
      end

      context "with unpermitted parameter" do 

        it "should_receive permit" do 
          @comment.should_receive(:build).with({"body"=>"Test Comment", "resource_id"=>@asset.id.to_s})
        end
        
        it "should_not_receive permit with unpermitted data" do 
          @comment.should_receive(:build).with({"body"=>"Test Comment", "resource_id"=>@asset.id.to_s})
        end

        after do
          xhr :post, :create, comment: {resource_id: @asset.id, body: "Test Comment"}
        end
      end
    end
  end

  describe "#resource_class" do 
    before do 
      should_authorize(:create, Comment)
      @resource_class_params = "assets"
      @resource_class = "Asset"
      Asset.stub(:unscoped).and_return(Asset)
      Asset.stub(:where).with(id: @asset.id.to_s, company_id: company.id).and_return(@assets)
      @asset.stub(:comments).and_return(@comment)
      @comment.stub(:includes).with(:commenter).and_return(@comment)
      @comment.stub(:build).and_return(@comment)
      @comment.stub(:save).and_return(true)
      @comment.stub(:order).with("created_at desc").and_return(@comment)
      @resource_class_params.stub(:classify).and_return(@resource_class)
    end

    it "should_receive classify" do 
      @resource_class_params.should_receive(:classify).and_return(@resource_class)
    end

    it "should_receive constantize" do 
      @resource_class.should_receive(:constantize).twice.and_return(Asset)
    end

    after do 
      xhr :post, :create, comment: {resource_id: @asset.id, comment: "Test Comment"}, resource_class: @resource_class_params
    end
  end

end