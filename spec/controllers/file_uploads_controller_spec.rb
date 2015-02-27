require 'spec_helper'
include ControllerHelper

describe FileUploadsController do
  shared_examples_for "call before_action load_resource for file_uploads" do 
    it "Ticket should_receive find" do 
      FileUpload.should_receive(:find).and_return(file_upload)
      send_request
    end

    context "record found" do 
      it "should assign instance variable" do 
        send_request
        expect(assigns[:file_upload]).to eq(file_upload)
      end
    end

    context "record not found" do 
      before do 
        FileUpload.stub(:find).and_return(nil)
      end

      it "should raise exception" do 
        expect{ send_request }.to raise_exception
      end
    end
  end

  let(:company) { mock_model(Company) }
  let(:employee) { mock_model(Employee) }
  let(:ticket) { mock_model(Ticket) }
  let(:ticket_type) { mock_model(TicketType) }
  let(:file_upload) {mock_model(FileUpload)}
  let(:asset) {mock_model(Asset)}

  before do
    @admin = employee
    @file_uploads = [file_upload]
    @tickets = [ticket]
    controller.stub(:current_employee).and_return(@admin)
    controller.stub(:authenticate_employee!).and_return(@admin)
    controller.stub(:current_company).and_return(company)
    controller.stub(:logout_if_disable).and_return(true)
    controller.stub(:verify_current_company)
    employee.stub(:has_role?).with(:admin).and_return(true)
    employee.stub(:has_role?).with(:super_admin).and_return(false)
  end

  describe "DESTROY" do 
    def send_request
      xhr :delete, :destroy, id: file_upload.id
    end
    
    it_should "should_receive authorize_resource"
    it_should "call before_action load_resource for file_uploads"

    before do 
      should_authorize(:destroy, file_upload)
      FileUpload.stub(:find).and_return(file_upload)
      file_upload.stub(:destroy).and_return(true)
      file_upload.stub(:asset).and_return(asset)
      asset.stub(:file_uploads).and_return(@file_uploads)
      @file_uploads.stub(:build).and_return(file_upload)
      file_upload.stub(:file_file_name).and_return("Test")
    end

    describe "should_receive methods" do 
      it "should_receive asset" do 
        file_upload.should_receive(:asset).and_return(asset)
      end

      it "should_receive file_uploads" do 
        asset.should_receive(:file_uploads).and_return(@file_uploads)
      end

      it "should_receive build" do 
        @file_uploads.should_receive(:build).and_return(file_upload)
      end

      it "should_receive destroy" do 
        file_upload.should_receive(:destroy).and_return(true)
      end

      after do 
        send_request
      end
    end

    it "should assigns instance variable" do 
      send_request
      expect(assigns[:asset]).to eq(asset)
    end

    it "should render_template destroy" do
      send_request
      response.should render_template "destroy"
    end

    context "record destroyed" do 
      it "should have a flash notice" do 
        send_request
        flash[:notice].should eq("#{file_upload.file_file_name} has been removed successfully")
      end
    end

    context "record not destroyed" do 
      before do 
        file_upload.stub(:destroy).and_return(false)
      end
      
      it "should have a flash alert" do 
        send_request
        flash[:alert].should eq("#{file_upload.file_file_name} could not removed, please try again.")
      end
    end
  end

end
