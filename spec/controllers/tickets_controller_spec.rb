require 'spec_helper'
include ControllerHelper

describe TicketsController do
  shared_examples_for 'call before_action :find_ticket' do

    describe "should_receive methods" do 
      it "controller should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "company should_receive tickets" do 
        company.should_receive(:tickets).and_return(@tickets)
      end

      it "tickets should_receive where" do 
        @tickets.should_receive(:where).with(id: ticket.id.to_s).and_return([ticket])
      end

      after do 
        send_request
      end
    end

    context "Employee is admin" do 
      before do 
        employee.stub(:has_role?).with(:admin).and_return(true)
      end

      it "should_not_receive where with employee_id" do 
        @tickets.should_not_receive(:where).with(employee_id: employee.id)
        send_request
      end
    end

    context "Employee is not admin" do 
      before do 
        employee.stub(:has_role?).with(:admin).and_return(false)
      end

      it "should_receive where with employee_id" do 
        @tickets.should_receive(:where).with(employee_id: employee.id).and_return(@tickets)
        send_request
      end
    end

    context "tickets not present" do 
      before do 
        company.stub(:tickets).and_return(@tickets)
        @tickets.stub(:where).with(id: ticket.id.to_s).and_return([])
        request.env["HTTP_REFERER"] = root_path
        send_request
      end

      it "should redirect_to root_path" do 
        response.should redirect_to root_path
      end

      it "should have flash alert" do 
        flash[:alert].should eq("The ticket you are looking for does not exist.")
      end
    end

    context "tickets present" do 
      before do 
        send_request
      end

      it "should not redirect_to root_path" do 
        response.should_not redirect_to root_path
      end

      it "should not have flash alert" do 
        flash[:alert].should_not eq("The ticket you are looking for does not exist.")
      end
    end
  end

  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee) }
  let(:ticket) { mock_model(Ticket) }
  let(:ticket_type) { mock_model(TicketType) }
  let(:comment) { mock_model(Comment) }

  before do
    @admin = employee
    @comments = [comment]
    @tickets = [ticket]
    @valid_attributes = { ticket_type_id: ticket_type.id, employee_id: employee.id, description: "Test description"}
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
      get :index, page: "1"
    end

    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:index, Ticket)
      company.stub(:tickets).and_return(@tickets)
      @tickets.stub(:includes).with({asset: :asset_type}, :ticket_type, :employee).and_return(@tickets)
      @tickets.stub(:order).with("created_at desc").and_return(@tickets)
      @tickets.stub(:page).with("1").and_return(@tickets)
      @tickets.stub(:per_page).with(PER_PAGE).and_return(@tickets)
    end

    it "should assigns instance variable" do 
      send_request
      expect(assigns[:tickets]).to eq(@tickets)
    end

    it "should render template index" do 
      send_request
      response.should render_template "index"
    end

    describe "should_receive methods" do 
      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive tickets" do 
        company.should_receive(:tickets).and_return(@tickets)
      end

      it "should_receive includes" do 
        @tickets.should_receive(:includes).with({asset: :asset_type}, :ticket_type, :employee).and_return(@tickets)
      end

      it "should_receive order" do 
        @tickets.should_receive(:order).with("created_at desc").and_return(@tickets)
      end

      it "should_receive page" do 
        @tickets.should_receive(:page).with("1").and_return(@tickets)
      end

      it "should_receive per_page" do 
        @tickets.should_receive(:per_page).with(PER_PAGE).and_return(@tickets)
      end

      after do 
        send_request
      end
    end

    context "employee is admin" do 
      it "should not receive where" do 
        @tickets.should_not_receive(:where)
        send_request
      end
    end

    context "employee is not admin" do 
      before do 
        employee.stub(:has_role?).with(:admin).and_return(false)
        @tickets.stub(:where).with(employee_id: employee.id).and_return(@tickets)
      end

      it "should_receive where" do 
        @tickets.should_receive(:where).with(employee_id: employee.id).and_return(@tickets)
        send_request
      end

      it "should assigns instance variable" do 
        send_request
        expect(assigns[:tickets]).to eq(@tickets)
      end
    end

    context "params[:state] present" do 
      def send_request
        get :index, state: "open", page: "1"
      end

      before do 
        @tickets.stub(:where).with(state: Ticket::STATE[:open]).and_return(@tickets)
      end

      it "should_receive where" do 
        @tickets.should_receive(:where).with(state: Ticket::STATE[:open]).and_return(@tickets)
        send_request
      end

      it "should assigns instance variable" do 
        send_request
        expect(assigns[:tickets]).to eq(@tickets)
      end
    end

    context "params[:type] not present" do 
      it "should_not_receive where" do 
        @tickets.should_not_receive(:where)
        send_request
      end
    end

  end

  describe "NEW" do 
    def send_request
      get :new
    end
    
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:new, Ticket)
      company.stub(:tickets).and_return(@tickets)
      @tickets.stub(:build).and_return(ticket)
    end

    describe "should_receive methods" do 
      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive tickets" do 
        company.should_receive(:tickets).and_return(@tickets)
      end

      it "should_receive build" do 
        @tickets.should_receive(:build).and_return(ticket)
      end

      after do 
        send_request
      end
    end

    it "should assigns instance variable" do 
      send_request
      expect(assigns[:ticket]).to eq(ticket)
    end

    it "should render_template new" do 
      send_request
      response.should render_template  "new"
    end
  end

  describe "CREATE" do 
    def send_request
      post :create, ticket: @valid_attributes
    end
    
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:create, Ticket)
      controller.stub(:params_ticket).and_return(@valid_attributes)
      company.stub(:tickets).and_return(@tickets)
      @tickets.stub(:build).with(@valid_attributes).and_return(ticket)
      ticket.stub(:save).and_return(true)
      ticket.stub(:employee=).and_return(employee)
      ticket.stub(:title).and_return("Ticket ##{ticket.id}")
    end

    describe "should_receive methods" do 

      it "should_receive params_ticket" do 
        controller.should_receive(:params_ticket).and_return(@valid_attributes)
      end

      it "should_receive company" do 
        controller.should_receive(:current_company).and_return(company)
      end

      it "should_receive tickets" do 
        company.should_receive(:tickets).and_return(@tickets)
      end

      it "should_receive build" do 
        @tickets.should_receive(:build).with(@valid_attributes).and_return(ticket)
      end

      it "should_receive save" do 
        ticket.should_receive(:save).and_return(true)
      end

      it "should_receive employee" do 
        ticket.should_receive(:employee=).and_return(employee)
      end

      it "should_receive title" do 
        ticket.should_receive(:title)
      end

      after do 
        send_request
      end
    end

    it "should assigns instance variable" do 
      send_request
      expect(assigns[:ticket]).to eq(ticket)
    end

    context "record created" do 
      it "should redirect_to index" do 
        send_request
        response.should redirect_to tickets_path
      end

      it "should have a flash notice" do 
        send_request
        flash[:notice].should eq("#{ticket.title} has been submitted successfully")
      end
    end

    context "record not created" do 
      before do 
        ticket.stub(:save).and_return(false)
      end

      it "should render_template new" do 
        send_request
        response.should render_template "new"
      end

      it "should not have a flash notice" do 
        send_request
        flash[:notice].should_not eq("Ticket has been submitted successfully")
      end
    end

  end

  describe "SHOW" do 
    def send_request
      get :show, id: ticket.id
    end
    
    it_should 'call before_action :find_ticket'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:show, ticket)
      company.stub(:tickets).and_return(@tickets)
      @tickets.stub(:where).with(id: ticket.id.to_s).and_return(@tickets)
      @tickets.stub(:where).with(employee_id: employee.id).and_return(@tickets)
      ticket.stub(:comments).and_return(@comments)
      @comments.stub(:includes).with(:commenter).and_return(@comments)
      @comments.stub(:order).with("created_at asc").and_return(@comments)
      @comments.stub(:build).and_return(comment)
    end

    describe "assigns instance variable" do 
      before do 
        send_request
      end

      it "should assigns instance variable comments" do 
        expect(assigns[:comments]).to eq(@comments)
      end

      it "should assigns instance variable comment" do 
        expect(assigns[:comment]).to eq(comment)
      end
    end

    it "should render_template show" do 
      send_request
      response.should render_template "show"
    end

    describe "should_receive methods" do 
      it "should_receive comments" do 
        ticket.should_receive(:comments).twice.and_return(@comments)
      end

      it "should_receive includes" do 
        @comments.should_receive(:includes).with(:commenter).and_return(@comments)
      end

      it "should_receive build" do 
        @comments.should_receive(:build).and_return(comment)
      end

      it "should_receive order" do 
        @comments.should_receive(:order).with("created_at asc").and_return(@comments)
      end

      after do 
        send_request
      end
    end

  end

  describe "#change_state" do 
    def send_request
      put :change_state, id: ticket.id
    end
    
    it_should 'call before_action :find_ticket'
    it_should "should_receive authorize_resource"

    before do 
      should_authorize(:change_state, ticket)
      ticket.stub(:change_state!).and_return(true)
      company.stub(:tickets).and_return(@tickets)
      @tickets.stub(:where).with(id: ticket.id.to_s).and_return(@tickets)
      ticket.stub(:state).and_return(1)
      ticket.stub(:open?).and_return(true)
      ticket.stub(:title).and_return("Ticket ##{ticket.id}")
      request.env["HTTP_REFERER"] = tickets_path
    end

    it "should_receive change_state!" do 
      ticket.should_receive(:change_state!).and_return(true)
      send_request
    end

    it "should redirect_to back" do 
      send_request
      response.should redirect_to tickets_path
    end

    it "should have a flash notice" do 
      send_request
      flash[:notice].should eq("#{ticket.title} #{ticket.open? ? 'reopened' : 'closed'} successfully")
    end

    it "should_receive title" do 
      ticket.should_receive(:title)
      send_request
    end
  end

  describe "#params_ticket" do 
    def send_request
      post :create, ticket: @valid_attributes
    end
    
    before do 
      should_authorize(:create, Ticket)
      @attributes = {color: "red",ticket_type_id: ticket_type.id, employee_id: employee.id, description: "Test description"}
      company.stub(:tickets).and_return(@tickets)
      @tickets.stub(:build).and_return(ticket)
      ticket.stub(:save).and_return(true)
      ticket.stub(:employee=).and_return(employee)
      ticket.stub(:title)
    end

    it "ticket should_receive build with permitted parameters only" do 
      @tickets.should_receive(:build).with({"ticket_type_id"=>ticket_type.id.to_s, "description"=>"Test description", "employee_id"=>employee.id.to_s})
    end

    it "should_not_receive with unpermitted parameters" do 
      @tickets.should_not_receive(:build).with({"color"=>"red","ticket_type_id"=>"1294", "description"=>"Test description", "employee_id"=>"1291"})
    end

    after do 
      send_request
    end

  end

  describe "#search" do 
    def send_request
      xhr :get, :search, page: 1, category: "Id", search_query: "test", state: "closed" 
    end

    before do 
      should_authorize(:search, Ticket)
      Ticket.stub(:search).with("Id", "closed", "test", employee).and_return(@tickets)
      @tickets.stub(:includes).with({asset: :asset_type}, :ticket_type, :employee).and_return(@tickets)
      @tickets.stub(:page).with("1").and_return(@tickets)
      @tickets.stub(:per_page).with(PER_PAGE).and_return(@tickets)
    end

    describe "should_receive methods" do 
      it "should_receive search" do 
        Ticket.should_receive(:search).with("Id", "closed", "test", employee).and_return(@tickets)
      end

      it "should_receive includes" do 
        @tickets.should_receive(:includes).with({asset: :asset_type}, :ticket_type, :employee).and_return(@tickets)
      end

      it "should_receive paginate" do 
        @tickets.should_receive(:per_page).with(PER_PAGE).and_return(@tickets)
      end

      after do 
        send_request
      end
    end

    describe "assigns instance variable" do 
      it "should assigns instance variable" do 
        send_request
        expect(assigns[:tickets]).to eq(@tickets)
      end
    end

    describe "render_template" do 
      it "should render_template search" do 
        send_request
        response.should render_template "search"
      end
    end

  end


end
