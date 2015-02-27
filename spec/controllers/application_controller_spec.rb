require "spec_helper"

describe ApplicationController do
  let(:company) { mock_model(Company,:save => true, :id => 1, :permalink => "test") }
  let(:employee) { mock_model(Employee, :save => true, :employee_id => 53, :name => "Ishank Gupta", :email => "ishank_18@yahoooo.com","company_id"=>company.id) }
  
  before do
    @admin = employee
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    @admin.stub(:disabled?).and_return(true)
    @admin.stub(:company).and_return(company)
    company.stub(:disabled?).and_return(false)
    company.stub(:verify_current_company)
    @admin.stub(:has_role?).with(:super_admin).and_return(true)
  end

  controller do
    before_filter :set_current_employee
    before_filter :logout_if_disable
    before_filter :verify_current_company

    def index
      render :nothing => true
    end

    def show
      raise CanCan::AccessDenied
    end

    def update
      raise ActionController::RedirectBackError 
    end

    def unknown_format
      raise ActionController::UnknownFormat
    end
  end

  describe "rescue_from CanCan::AccessDenied" do 
    def send_request
      get :show, id: "abc"
    end

    it "should redirect_to root_url" do 
      send_request
      response.should redirect_to root_url
    end

    it "should throw exception message" do 
      send_request
      flash[:alert].should eq("You are not authorized to access this page.")
    end
  end

  describe "rescue_from ActionController::RedirectBackError " do 
    def send_request
      get :update, id: "abc"
    end

    it "should redirect_to root_url" do 
      send_request
      response.should redirect_to root_url
    end

    it "should throw exception message" do 
      send_request
      flash[:alert].should eq("Page not found.")
    end
  end

  describe "rescue_from ActionController::UnknownFormat " do 
    before do 
      @routes.draw { get '/anonymous/unknown_format' }
    end

    def send_request
      get :unknown_format, id: "abc"
    end

    it "should redirect_to root_url" do 
      send_request
      response.should redirect_to root_url
    end

    it "should throw exception message" do 
      send_request
      flash[:alert].should eq("Invalid Request.")
    end
  end

  describe "before_filter logout_if_disable" do 
    def send_request
      get :index
    end

    before do 
      controller.stub(:set_current_employee)
      controller.stub(:verify_current_company)
    end
    describe "should_receive methods" do 
      
      it "should_receive logout_if_disable" do
        controller.should_receive(:logout_if_disable)
      end
      
      context "current_employee is not present" do 
      
        before do 
          controller.stub(:current_employee).and_return(nil)
        end

        it "should_not_receive destroy_employee_session_path" do
          controller.should_not_receive(:destroy_employee_session_path)
        end

        it "should_not_receive disabled" do
          employee.should_not_receive(:disabled?)
        end

        it "should_not_receive company" do 
          employee.should_not_receive(:company)
        end

        it "should_not_receive disabled for company" do 
          company.should_not_receive(:disabled?)
        end
      end

      context "current_employee present" do 
        before do 
          employee.stub(:has_role?).with(:super_admin).and_return(false)
        end

        it "should_receive has_role?" do 
          employee.should_receive(:has_role?).with(:super_admin).and_return(false)
          send_request
        end

        context "super_admin" do 
          before do 
            employee.stub(:has_role?).with(:super_admin).and_return(true)
          end

          it "should_not_receive destroy_employee_session_path" do 
            controller.should_not_receive(:destroy_employee_session_path)
          end

          it "should_not_receive disabled?" do 
            employee.should_not_receive(:disabled?)
          end

          it "company should_not_receive disabled" do 
            company.should_not_receive(:disabled?)
          end

          it "should_not_receive company" do 
            employee.should_not_receive(:company)
          end

          after do 
            send_request
          end
        end

        context "not super_admin" do 

          context "current_employee is disabled" do 
            before do 
              employee.stub(:disabled?).and_return(true)
            end

            it "should_receive destroy_employee_session_path" do
              controller.should_receive(:destroy_employee_session_path)
            end

            it "should_receive disabled" do
              employee.should_receive(:disabled?).and_return(true)
            end

            it "should_receive current_employee" do 
              controller.should_receive(:current_employee).and_return(employee)
            end
          end

          context "current_employee is not disabled" do 

            before do 
              employee.stub(:disabled?).and_return(false)
            end

            context "current_employee company is disabled" do 
            
              before do 
                company.stub(:disabled?).and_return(true)
              end
      
              it "should_receive destroy_employee_session_path" do
                controller.should_receive(:destroy_employee_session_path)
              end

              it "should_receive disabled" do
                employee.should_receive(:disabled?).and_return(true)
              end

              it "should_receive company" do 
                employee.should_receive(:company).and_return(company)
              end

              it "should_receive disabled for company" do 
                company.should_receive(:disabled?).and_return(true)
              end
            end

            context "current_employee company is not disabled" do 

              before do 
                company.stub(:disabled?).and_return(false)
              end
              
              it "should_not_receive destroy_employee_session_path" do
                controller.should_not_receive(:destroy_employee_session_path)
              end

              it "should_receive disabled" do
                employee.should_receive(:disabled?).and_return(false)
              end

              it "should_receive company" do 
                employee.should_receive(:company).and_return(company)
              end

              it "should_receive disabled for company" do 
                company.should_receive(:disabled?).and_return(true)
              end
            end
          end
        end
      end

      after do 
        send_request
      end
    end
  end

  describe "before_filter set_current_employee" do 
    def send_request
      get :index
    end

    before do 
      controller.stub(:logout_if_disable)
    end

    describe "should_receive methods" do 

      it "should_receive set_current_employee" do 
        controller.should_receive(:set_current_employee)
        send_request
      end

      it "should set the admin" do 
        send_request
        Thread.current[:audited_admin].should eq(employee)
      end

      it "should set request ip" do 
        send_request
        Thread.current[:ip].should eq(request.try(:ip))
      end
    end
  end

  describe "before_filter verify_current_company" do 
    def send_request
      get :index
    end

    before do 
      controller.stub(:logout_if_disable)
      controller.stub(:set_current_employee)
    end

    context "current_employee not present" do 
      before do 
        controller.stub(:current_employee).and_return(nil)
      end
      it "should_not_receive permalink" do 
        company.should_not_receive(:permalink)
        send_request
      end

      it "should_not redirect_to root_path" do 
        send_request
        response.should_not redirect_to root_path
      end
    end

    context "employee present" do 
      context "has_role?(:super_admin) true" do 
        before do 
          employee.stub(:has_role?).with(:super_admin).and_return(true)
        end
        it "should_not_receive permalink" do 
          company.should_not_receive(:permalink)
          send_request
        end

        it "should_not redirect_to root_path" do 
          send_request
          response.should_not redirect_to root_path
        end      
      end

      context "has_role?(:super_admin) false" do 
        before do 
          employee.stub(:has_role?).with(:super_admin).and_return(false)
        end

        it "should_receive permalink" do 
          company.should_receive(:permalink)
          send_request
        end

        context "permalink is params[:current_company]" do 
          before do 
            company.stub(:permalink).and_return('test')
          end

          it "should_not redirect_to root_path" do 
            get :index, current_company: company.permalink 
            response.should_not redirect_to root_path
          end
        end

        context "permalink is not params[:current_company]" do 
          before do 
            company.stub(:permalink).and_return('abc')
          end

          it "should redirect_to root_path" do 
            send_request
            response.should redirect_to root_path
          end
        end
      end
    end
  end

  describe "default_url_options" do 
    def send_request
      get :index
    end

    before do 
      controller.stub(:logout_if_disable)
      controller.stub(:set_current_employee)
      controller.stub(:verify_current_company)
      @controller = ApplicationController.new
    end

    context "current_employee is not present" do 
      before do 
        @controller.stub(:current_employee).and_return(nil)
      end

      it "should_not_receive permalink" do 
        company.should_not_receive(:permalink)
        @controller.default_url_options
      end
      
      it "should return blank hash " do 
        @controller.default_url_options.should eq({})
      end
    end

    context "current_employee is present" do 
      before do 
        @controller.stub(:current_employee).and_return(employee)
      end

      context "has_role?(:super_admin) return false" do 
        before do 
          employee.stub(:has_role?).with(:super_admin).and_return(false)
        end

        it "should_receive permalink" do 
          company.should_receive(:permalink)
          @controller.default_url_options
        end
        
        it "should return blank hash " do 
          @controller.default_url_options.should eq({:current_company => company.permalink})
        end
      end

      context "has_role?(:super_admin) return true" do 
        before do 
          employee.stub(:has_role?).with(:super_admin).and_return(true)
        end
                 
        it "should_not_receive permalink" do 
          company.should_not_receive(:permalink)
          @controller.default_url_options
        end
        
        it "should return blank hash " do 
          @controller.default_url_options.should eq({})
        end
      end
    end
  end

  describe "current_company" do 
    
    before do 
      @controller = ApplicationController.new
      @controller.stub(:current_employee).and_return(employee)
      employee.stub(:company).and_return(company)
    end

    describe "should_receive methods" do 

      it "should_receive current_employee" do 
        @controller.should_receive(:current_employee).and_return(employee)
      end

      context "employee not present" do 
        before do 
          @controller.stub(:current_employee).and_return(nil)
        end

        it "current_employee should_not_receive company" do 
          employee.should_not_receive(:company)
        end
      end

      context "employee present" do 

        it "current_employee should_receive company" do 
          employee.should_receive(:company).and_return(company)
        end
      end

      after do 
        @controller.current_company
      end
    end
  end

end