shared_examples_for 'send ticket creation notification' do

  describe "after_create #send_ticket_creation_mail" do 
    before do 
      @ticket1 = Ticket.new(ticket_type_id: @ticket_type.id, description: "Test desc", employee_id: @employee.id, state: Ticket::STATE[:open], company_id: @company.id)
    end

    describe "should_receive_methods" do 
      before do 
        TicketNotifier.stub(:delay).and_return(TicketNotifier)
        TicketNotifier.stub(:ticket_creation_notification).with(@ticket1)
      end

      it "should_receive delay" do 
        TicketNotifier.should_receive(:delay).and_return(TicketNotifier)
      end

      it "should_receive ticket_creation_notification" do 
        TicketNotifier.should_receive(:ticket_creation_notification).with(@ticket1)
      end

      after do 
        @ticket1.save
      end
    end

    it "should increase delayed job count" do 
      count = Delayed::Job.count
      @ticket1.save
      Delayed::Job.count.should eq(count + 1)
    end
  end

end