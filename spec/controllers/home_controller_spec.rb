require 'spec_helper'
include ControllerHelper

describe HomeController do

  shared_examples_for 'call before_action :assign_variables' do |params_attr|
    describe "assign instance variables" do 
      before do 
        send_request
      end

      it "should assign asset" do 
        expect(assigns[:asset]).to eq(params_attr[:asset])
      end
      it "should assign status" do 
        expect(assigns[:status]).to eq(params_attr[:status])
      end
      it "should assign employee" do 
        expect(assigns[:opt_employee]).to eq(params_attr[:employee])
      end
      it "should assign category" do 
        expect(assigns[:category]).to eq(params_attr[:category])
      end
      it "should assign to date" do 
        expect(assigns[:to]).to eq(params_attr[:to])
      end
      it "should assign from date" do 
        expect(assigns[:from]).to eq(params_attr[:from])
      end
    end
  end

  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee, :save => true, :id => 1,:employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com") }
  let(:aem) { mock_model(Assignment, :save => true, :employee_id => 4, :asset_id => 1, :date_returned => DateTime.now, :remark => "assign") }
  let(:tag) { mock_model(Tag, :save => true, :name => "ubuntu") }
  let(:asset_type)  { mock_model(AssetType, :save => true, "id"=>1, "name"=>"laptop", "company_id"=>company.id) }
  let(:asset)  { mock_model(Asset, :save => true,"asset_type_id"=>asset_type.id, "name"=>"Test Name", "status"=>"spare", "type"=>"Laptop", "currency_unit"=>"&#8377;", "cost"=>"100.0", "serial_number"=>"YUIYIU78sdf789IU", "vendor"=>"Test", "purchase_date"=>"29/09/2011", "resource_attributes"=>{"operating_system"=>"TEST OS", "has_bag"=>"false"}, "description"=>"Test Desc", "additional_info"=>"Test ADD Info") }
  let(:assignment) {mock_model(Assignment)}

  before do 
    @admin = employee
    @tags = [tag]
    @assets = [asset]
    @employees = [employee]
    @assignments = [assignment]
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    controller.stub(:verify_current_company)
    company.stub(:id).and_return(company.id)
    controller.stub(:logout_if_disable).and_return(true)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
    asset.stub(:asset_type).and_return(asset_type)
  end

  describe "INDEX" do

    def send_request
      get :index, :page => "1"
    end
    
    context "current_employee is admin" do 
      before do 
        company.stub(:tags).and_return(@tags)
        @tags.stub(:includes).with(:assets).and_return(@tags)
        @tags.stub(:paginate).with(:page => "1", :per_page => 100).and_return(@tags)
      end

      describe "should_receive methods" do 

        it "should_receive company" do 
          controller.should_receive(:current_company).and_return(company)
        end

        it "company should_receive tags" do
          company.should_receive(:tags).and_return(@tags)
        end

        it "tags should_receive includes" do 
          @tags.should_receive(:includes).with(:assets).and_return(@tags)
        end

        it "tags should_receive paginate" do 
          @tags.should_receive(:paginate).with(:page => "1", :per_page => 100).and_return(@tags)
        end

        after do 
          send_request
        end
      end

      it "should assigns instance varable tags" do 
        send_request
        expect(assigns[:tags]).to eq(@tags)
      end

      it "should render_template index" do 
        send_request
        response.should render_template("index")
      end

    end

    context "current_employee is super_admin" do 
      before do 
        employee.stub(:has_role?).with(:super_admin).and_return(true)
      end

      it "should redirect_to company index" do 
        send_request
        response.should redirect_to companies_path
      end
    end

    context "current_employee is not admin" do 
      before do 
        employee.stub(:has_role?).with(:admin).and_return(false)
        employee.stub(:active_assignments).and_return(@assignments)
        @assignments.stub(:includes).with(:asset).and_return(@assignments)
      end

      it "should_receive current_employee" do 
        controller.should_receive(:current_employee).and_return(employee)
        send_request
      end

      it "should_receive active_assignments" do 
        employee.should_receive(:active_assignments).and_return(@assignments)
        send_request
      end

      it "should_receive includes" do 
        @assignments.should_receive(:includes).with(:asset).and_return(@assignments)
        send_request
      end

      it "should assign instance varable" do 
        send_request
        expect(assigns[:assignments]).to eq(@assignments)
      end

      it "should render_template index" do 
        send_request
        response.should render_template("index")
      end
    end

  end

  describe "show_tag" do 
    def send_request
      xhr :get, :show_tag, tag_id: tag.id, page: "1", order: "created_at asc"
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:read, employee)
      Tag.stub(:where).with(id: tag.id.to_s).and_return([tag])
      tag.stub(:assets).and_return(@assets)
      @assets.stub(:paginate).with(:page => "1", :order=>"created_at asc", :per_page=> 100).and_return(@assets)
    end

    describe "should_receive methods" do 
      it "Tag should_receive where" do 
        Tag.should_receive(:where).with(id: tag.id.to_s).and_return([tag])
      end

      it "tag should_receive assets" do 
        tag.should_receive(:assets).and_return(@assets)
      end

      it "assets should_receive paginate" do 
        @assets.should_receive(:paginate).with(:page => "1", :order=>"created_at asc", :per_page=>100).and_return(@assets)
      end

      after do 
        send_request
      end
    end

    it "should render_template show_tag" do 
      send_request
      response.should render_template "show_tag"
    end

    it "should assigns instance varable tag" do 
      send_request
      expect(assigns[:tag]).to eq(tag)
    end

    it "should assigns instance variable assets" do 
      send_request
      expect(assigns[:assets]).to eq(@assets)
    end
  end

  describe "#search" do 
    def send_request
      xhr :get, :search, @params_attr.merge!({page: "1"})
    end

    it_should 'call before_action :assign_variables', {asset: "test", status: 'spare', employee: 1}
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:read, employee)
      @params_attr = {asset: "test", status: 'spare', employee: employee.id}
      company.stub(:assets).and_return(@assets)
      @assets.stub(:paginate).with(page: "1", per_page: 100).and_return(@assets)
      @assets.stub(:search).with('test', 'spare', nil, nil, nil, employee.id).and_return(@assets)
      controller.stub(:has_asset_attributes?).and_return(true)
    end

    it "should assigns result" do 
      send_request
      expect(assigns[:result]).to eq(@assets)
    end
    
    it "should render_template search" do 
      send_request
      response.should render_template "search"
    end

    context "params[:barcode] present" do 
      before do 
        controller.stub(:find_asset_from_barcode).and_return(asset)
      end

      it "controller should_receive find_asset_from_barcode" do 
        controller.should_receive(:find_asset_from_barcode).and_return(:asset)
        get :search, barcode: '0001000001'
      end
    end

    context "params[:barcode] is not present" do 
      before do 
        controller.stub(:has_asset_attributes?).and_return(true)
        @assets.stub(:search).with('test', 'spare', nil, nil, nil, employee.id).and_return(@assets)
      end

      it "controller should_receive find_asset_from_barcode" do 
        controller.should_not_receive(:find_asset_from_barcode)
        send_request
      end
    end

    context "params[:tag] present" do 
      before do 
        controller.stub(:find_assets_from_tag).and_return(@assets)
      end

      it "controller should_receive find_assets_from_tag" do 
        controller.should_receive(:find_assets_from_tag).and_return(@assets)
        xhr :get, :search, tag: "test", page: "1"
      end
    end

    context "params[:tag] not present" do 
      before do 
        controller.stub(:find_asset_from_barcode).and_return(asset)
      end
      
      it "controller should_receive find_assets_from_tag" do 
        controller.should_not_receive(:find_assets_from_tag)
        get :search, barcode: '0001000001'
      end
    end
    
    context "other attributes present" do
      context "asset attributes present" do 
        before do 
          controller.stub(:has_asset_attributes?).and_return(true)
          @assets.stub(:search).with('test', 'spare', nil, nil, nil, employee.id).and_return(@assets)
        end

        it "controller should_receive has_asset_attributes?" do 
          controller.should_receive(:has_asset_attributes?).and_return(true)
          send_request
        end

        it "should_receive assets" do 
          company.should_receive(:assets).and_return(@assets)
          send_request
        end
        
        it "should_receive search" do 
          @assets.should_receive(:search).with('test', 'spare', nil, nil, nil, employee.id).and_return(@assets)
          send_request
        end

        it "should assigns result" do 
          send_request
          expect(assigns[:result]).to eq(@assets)
        end
        
        context "result is blank" do 
          before do 
            @assets.should_receive(:search).with('test', 'spare', nil, nil, nil, employee.id).and_return([])
          end
          
          it "should_not_receive paginate" do 
            @assets.should_not_receive(:paginate)
            send_request
          end
        end

        context "result is not blank" do 

          context "params[:print] not present" do 
            it "should_receive paginate" do 
              @assets.should_receive(:paginate).with(page: "1", per_page: 100).and_return(@assets)
              send_request
            end
          end

          context "params[:print] are present" do 
            it "should_not_receive paginate"  do 
              @assets.should_not_receive(:paginate)
              xhr :get, :search, asset: "test", status: 'spare', employee: employee.id, print: true, page: "1", per_page: 100
            end
          end
        end
      end

      context "asset attributes not present" do 
        def send_request
          xhr :get, :search, employee: 'test', page: "1", per_page: 100
        end

        before do 
          controller.stub(:has_asset_attributes?).and_return(false)
          company.stub(:employees).and_return(@employees)
          @employees.stub(:where).with("employees.name like ?", '%test%').and_return(@employees)
          @employees.stub(:paginate).with(page: "1", per_page: 100).and_return(@employees)
        end

        it "should_receive find_employees" do 
          controller.should_receive(:find_employees).and_return(@employees)
          send_request
        end
        
        context "result is blank" do 
          before do 
            @employees.stub(:where).with("employees.name like ?", '%test%').and_return([])  
          end

          it "should_not_receive paginate" do 
            @employees.should_not_receive(:paginate)
            send_request
          end
        end

        context "result is not blank" do 
          context "params[:print] not present" do 
            it "should_receive paginate" do 
              @employees.should_receive(:paginate).with(page: "1", per_page: 100).and_return(@employees)
              send_request
            end
          end

          context "params[:print] are present" do 
            it "should_not_receive paginate"  do 
              @employees.should_not_receive(:paginate)
              xhr :get, :search, employee: 'test', print: true, page: "1", per_page: 100   
            end
          end
        end
      end
    end
  end

  describe "find_asset_from_barcode" do 

    def send_request
      get :search, barcode: @barcode
    end

    before do 
      should_authorize(:read, employee)
      @barcode = "0001000001"
      Asset.stub(:where).with(barcode: @barcode).and_return([asset])
    end

    it "should_receive where" do 
      Asset.should_receive(:where).with(barcode: @barcode).and_return([asset])
      send_request
    end

    it "should assign asset" do 
      send_request
      expect(assigns[:asset]).to eq(asset)
    end

    context "asset present" do 
      it "should redirect_to show" do 
        send_request
        response.should redirect_to [asset.asset_type, asset]
      end
    end

    context "asset not present" do 
      before do 
        Asset.stub(:where).with(barcode: @barcode).and_return([])  
      end

      it "should have flash" do 
        send_request
        flash[:alert].should eq("No Asset found with barcode: #{@barcode}")
      end

      it "response should redirect" do 
        send_request
        response.should_not redirect_to asset
      end
    end
  end

  describe "find_assets_from_tag" do 
    def send_request
      xhr :get, :search, tag: tag.name, page: 1
    end

    before do 
      should_authorize(:read, employee)
      company.stub(:tags).and_return(@tags)
      @tags.stub(:where).with(name: tag.name).and_return(@tags)
      tag.stub(:assets).and_return(@assets)
      @assets.stub(:paginate).with(page: "1", per_page: 100).and_return(@assets)
    end

    describe "should_receive methods" do 
      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive tags" do 
        company.should_receive(:tags).and_return(@tags)
      end

      it "should_receive where" do 
        @tags.should_receive(:where).with(name: tag.name).and_return(@tags)
      end

      after do 
        send_request
      end
    end

    context "tag present" do 
      it "should_receive assets" do 
        tag.should_receive(:assets).and_return(@assets)
        send_request
      end

      it "should assign instance varable result" do 
        send_request
        expect(assigns[:result]).to eq(@assets)
      end
    end

    context "tag not present" do 
      before do 
        @tags.stub(:where).with(name: tag.name).and_return([])
      end

      it "should_not_receive assets" do 
        tag.should_not_receive(:assets)
        send_request
      end
    end
  end

  describe "find_employees" do 
    before do 
      should_authorize(:read, employee)
      company.stub(:employees).and_return(@employees)
      @employees.stub(:paginate).with(page: "1", per_page: 100).and_return(@employees)
    end

    context "params[:employee] is id" do 
      def send_request
        xhr :get, :search, employee: employee.id.to_s, page: 1 
      end

      before do 
        controller.stub(:is_numeric?).and_return(true)
        @employees.stub(:where).with("employees.employee_id = ?", employee.id).and_return(@employees)
      end

      describe "should_receive methods" do 
        
        it "should_receive is_numeric?" do 
          controller.should_receive(:is_numeric?).and_return(true)
        end

        it "should_receive company" do 
          controller.should_receive(:current_company).and_return(company)
        end

        it "should_receive employees" do 
          company.should_receive(:employees).and_return(@employees)
        end

        it "should_receive where" do 
          @employees.should_receive(:where).with("employees.employee_id = ?", employee.id).and_return(@employees)
        end

        after do 
          send_request
        end
      end

      it "should assigns instance varable result" do 
        send_request
        expect(assigns[:result]).to eq(@employees)
      end
    end

    context "params[:employee] is name" do 
      def send_request
        xhr :get, :search, employee: employee.name, page: 1 
      end

      before do 
        controller.stub(:is_numeric?).with(employee.name).and_return(false)
        @employees.stub(:where).with("employees.name like ?", "%#{employee.name}%").and_return(@employees)
      end

      describe "should_receive methods" do 
      
        it "should_receive is_numeric?" do 
          controller.should_receive(:is_numeric?).with(employee.name).and_return(false)
        end

        it "should_receive company" do 
          controller.should_receive(:current_company).and_return(company)
        end


        it "should_receive employees" do 
          company.should_receive(:employees).and_return(@employees)
        end

        it "should_receive where" do 
          @employees.should_receive(:where).with("employees.name like ?",  "%#{employee.name}%").and_return(@employees)
        end

        after do 
          send_request
        end
      end

      it "should assigns instance varable result" do 
        send_request
        expect(assigns[:result]).to eq(@employees)
      end
    end
  end

  describe "has_asset_attributes?" do 
    def send_request
      xhr :get, :search, asset: 'test', page: 1 
    end

    before do 
      should_authorize(:read, employee)
      company.stub(:assets).and_return(@assets)
      @assets.stub(:paginate).with(page: "1", per_page: 100).and_return(@assets)
      @assets.stub(:search).with('test', nil, nil, nil, nil, nil).and_return(@assets)      
    end

    it "should return true if any value is present" do 
      send_request
      controller.send(:has_asset_attributes?).should eq(true)
    end

    context "no value is present" do 
      before do 
        company.stub(:employees).and_return(@employees)
        @employees.stub(:where).and_return(@employees)
        @employees.stub(:paginate).with(page: "1", per_page: 100).and_return(@employees)
      end

      it "should return false if any value is present" do 
        xhr :get, :search, page: 1 
        controller.send(:has_asset_attributes?).should eq(false)
      end      
    end
  end
end  
