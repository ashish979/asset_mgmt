shared_examples_for 'send comment notification' do

  describe "after_create #send_comment_notification" do 
    before do 
      @comment1 = Comment.new(body: "Testing", resource_id: ticket.id, resource_type: 'Ticket', commenter_id: employee.id)
      @comment1.stub(:commenter).and_return(employee)
    end

    describe "should_receive_methods" do 
      before do 
        TicketNotifier.stub(:delay).and_return(TicketNotifier)
        TicketNotifier.stub(:send_comment_notification).with(@comment1, employee)
      end

      it "should_receive delay" do 
        TicketNotifier.should_receive(:delay).and_return(TicketNotifier)
      end

      it "should_receive ticket_creation_notification" do 
        TicketNotifier.should_receive(:send_comment_notification).with(@comment1, employee)
      end

      after do 
        @comment1.save
      end
    end

    it "should increase delayed job count" do 
      count = Delayed::Job.count
      @comment1.save
      Delayed::Job.count.should eq(count + 1)
    end
  end

end