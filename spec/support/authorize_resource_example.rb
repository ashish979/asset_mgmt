shared_examples_for 'should_receive authorize_resource' do 

  it "should_receive authorize!" do 
    controller.should_receive(:authorize!).and_return(true)
  end

  after do 
    send_request
  end
end
