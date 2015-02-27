require 'spec_helper'

describe ConfirmationsController do

  shared_examples_for 'skip_before_filter :authenticate_employee!' do

    it "should_not_receive authenticate_employee!" do 
      controller.should_not_receive(:authenticate_employee!)
      send_request
    end
  end

  shared_examples_for 'skip_before_filter :require_no_authentication' do

    it "should_not_receive require_no_authentication" do 
      controller.should_not_receive(:require_no_authentication)
      send_request
    end
  end

  shared_examples_for 'call method :do_show' do

    it_should 'skip_before_filter :require_no_authentication'
    it_should 'skip_before_filter :authenticate_employee!'

    before do 
      send_request
    end
    
    it "should assign confirmation_token" do 
      expect(assigns[:confirmation_token]).to eq('xyzts245gh')
    end

    it "should assign confirmation_token" do 
      expect(assigns[:requires_password]).to eq(true)
    end

    it "should assign resource" do 
      controller.resource.should eq(employee)
    end

    it "should render show" do 
      response.should render_template 'show'
    end
  end

  shared_examples_for 'call method :do_confirm' do

    it_should 'skip_before_filter :require_no_authentication'
    it_should 'skip_before_filter :authenticate_employee!'

    it "should_receive confirm" do 
      employee.should_receive(:confirm!).and_return(true)
      send_request
    end
    
    it "should set flash message" do 
      send_request
      flash[:notice].should eq("Your account was successfully confirmed. You are now signed in.")
    end

    it "should redirect to sign_in_and_redirect" do 
      controller.should_receive(:sign_in_and_redirect).with(:employee, employee).and_return(true) 
      send_request
    end
  end

  shared_examples_for 'call method :with_unconfirmed_confirmable' do

    it_should 'skip_before_filter :require_no_authentication'
    it_should 'skip_before_filter :authenticate_employee!'

    it "should_receive find_or_initialize_with_error_by" do 
      Employee.should_receive(:find_or_initialize_with_error_by).with(:confirmation_token, "xyzts245gh").and_return(employee)
      send_request
    end

    it "should assigns instance variable confirmable" do 
      send_request
      expect(assigns[:confirmable]).to eq(employee)
    end

    context "employee is new" do 
      before do 
        employee.stub(:new_record?).and_return(true)
      end

      it "should_not receive only_if_unconfirmed" do 
        employee.should_not_receive(:only_if_unconfirmed)
        send_request
      end
    end

    context "employee is not new" do 
      before do 
        employee.stub(:new_record?).and_return(false)
      end

      it "should receive only_if_unconfirmed" do 
        employee.should_receive(:only_if_unconfirmed).and_yield
        send_request
      end
    end
  end

  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com") }

  before(:each) do 
    @request.env["devise.mapping"] = Devise.mappings[:employee]
    Employee.stub(:find_or_initialize_with_error_by).and_return(employee)
  end
  
  it "should be a child of Devise::ConfirmationsController" do
    controller.class.superclass.should eq Devise::ConfirmationsController
  end


  describe "SHOW" do 
    def send_request
      get :show,  confirmation_token: "xyzts245gh"
    end

    it_should 'skip_before_filter :require_no_authentication'
    it_should 'skip_before_filter :authenticate_employee!'
    it_should 'call method :with_unconfirmed_confirmable'

    before do 
      employee.stub(:only_if_unconfirmed).and_yield
      employee.stub(:has_no_password?).and_return(true)
      employee.stub(:errors).and_return([])
    end
    
    it "should_receive has_no_password?" do 
      employee.should_receive(:has_no_password?).and_return(true)
      send_request
    end

    context "has_no_password" do 

      it_should 'call method :do_show'

      it "should_not_receive do_confirm" do 
        controller.should_not_receive(:do_confirm)
        send_request
      end
    end

    context "has password" do 
      before do 
        employee.stub(:has_no_password?).and_return(false)
        employee.stub(:only_if_unconfirmed).and_yield
        employee.stub(:has_no_password?).and_return(false)
        employee.stub(:errors).and_return([])
        employee.stub(:confirm!).and_return(true)
        controller.stub(:sign_in_and_redirect).with(:employee, employee).and_return(true) 
      end
      
      it_should 'call method :do_confirm'
       
      it "should_not_receive do_show" do 
        controller.should_not_receive(:do_show)
      end 

      after do 
        send_request
      end
    end

    it "should_receive errors" do 
      employee.should_receive(:errors)
      send_request
    end

    context "employee has error" do 
      before do 
        @errors = ["not valid"]
        employee.stub(:errors).and_return(@errors)
        controller.stub(:do_show)
        controller.stub(:do_confirm)
      end

      it "should assign resource" do 
        send_request
        controller.resource.should eq(employee)
      end

      it "should render new" do 
        send_request
        response.should render_template 'devise/confirmations/new'
      end
    end

    context "employee has no error" do 
      before do 
        employee.stub(:errors).and_return([])
      end

      it "should_not render new" do 
        send_request
        response.should_not render_template 'devise/confirmations/new'
      end
    end
  end

  describe "UPDATE" do 
    def send_request
      put :update, employee: {password: 'vinsol123', password_confirmation: 'vinsol123'}, confirmation_token: "xyzts245gh"
    end

    it_should 'skip_before_filter :require_no_authentication'
    it_should 'skip_before_filter :authenticate_employee!'
    it_should 'call method :with_unconfirmed_confirmable'

    before do 
      employee.stub(:only_if_unconfirmed).and_yield
      employee.stub(:has_no_password?).and_return(true)
      employee.stub(:errors).and_return([])
      employee.stub(:attempt_set_password).with({"password"=>'vinsol123', "password_confirmation"=>'vinsol123'}).and_return(true)
      employee.stub(:confirm!).and_return(true)
      controller.stub(:sign_in_and_redirect).with(:employee, employee).and_return(true) 
    end
    
    it "should_receive has_no_password?" do 
      employee.should_receive(:has_no_password?).and_return(true)
      send_request
    end

    context "has no password" do 
      before do 
        employee.stub(:has_no_password?).and_return(true)
      end
      
      it "should_receive attempt_set_password" do 
        employee.should_receive(:attempt_set_password).with({"password"=>'vinsol123', "password_confirmation"=>'vinsol123'}).and_return(true)
        send_request      
      end

      context "valid?" do 
        before do 
          employee.stub(:valid?).and_return(true)
        end

        it_should 'call method :do_confirm'

        it "should_not_receive do_show" do 
          controller.should_not_receive(:do_show)
          send_request
        end
      end

      context "not valid" do 
        before do 
          employee.stub(:valid?).and_return(false)
          employee.stub(:errors).and_return([])
        end

        it_should 'call method :do_show'

        it "should_receive errors" do 
          employee.should_receive(:errors).and_return([])
          send_request
        end

        it "should_not_receive do_confirm" do 
          controller.should_not_receive(:do_confirm)
          send_request
        end
      end
    end

    context "has password" do 
      before do
        employee.stub(:has_no_password?).and_return(false)
        controller.class.stub(:add_error_on).with(controller, :email, :password_allready_set).and_return(true)
      end

      it "should_receive add_error_on" do 
        controller.class.should_receive(:add_error_on).with(controller, :email, :password_allready_set).and_return(true)
        send_request
      end
    end

    it "should_receive errors" do 
      employee.should_receive(:errors)
      send_request
    end


    context "employee has error" do 
      before do 
        @errors = ["not valid"]
        employee.stub(:errors).and_return(@errors)
      end

      it "should render new" do 
        send_request
        response.should render_template 'devise/confirmations/new'
      end
    end

    context "employee has no error" do 
      before do 
        employee.stub(:errors).and_return([])
      end

      it "should_not render new" do 
        send_request
        response.should_not render_template 'devise/confirmations/new'
      end
    end
  end
end
