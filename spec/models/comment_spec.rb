require 'spec_helper'

describe Comment do 

  it_should 'send comment notification'
  
  let(:asset) { mock_model(Asset) }
  let(:ticket) { mock_model(Ticket) }
  let(:employee) { mock_model(Employee) }

  before(:each) do
    @comment = Comment.new(body: "need to test it")
  end

  describe 'validation' do 
    context "resource_type is Assignment" do 
      before do 
        Comment.any_instance.stub(:resource_type).and_return("Assignment")
      end

      it { should_not validate_presence_of(:body) }

    end

    context "resource_type is Asset" do 
      before do 
        Comment.any_instance.stub(:resource_type).and_return("Asset")
      end

      it { should validate_presence_of(:body) }
    end

    context "resource_type is Asset" do 
      before do 
        Comment.any_instance.stub(:resource_type).and_return("Ticket")
      end

      it { should validate_presence_of(:body) }
    end
  end

  describe "association" do 
    it { should belong_to(:resource) }
    it { should belong_to(:commenter).class_name('Employee') }
  end

  describe "#destroyable?" do 

    context "resource_type is ticket" do 
      before do 
        @comment.stub(:resource_type).and_return('Ticket')
      end

      it "should return false" do 
        @comment.destroyable?.should eq(false)
      end
    end

    context "resource_type is not ticket" do 
      before do 
        @comment.stub(:resource_type).and_return('Assignment')
      end

      it "should return true" do 
        @comment.destroyable?.should eq(nil)
      end
    end
  end
end