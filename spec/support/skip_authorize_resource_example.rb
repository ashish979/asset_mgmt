shared_examples_for 'should_receive skip_authorize_resource' do 

  it "should_not_receive authorize!" do 
    controller.should_not_receive(:authorize!)
  end

  after do 
    send_request
  end
end
