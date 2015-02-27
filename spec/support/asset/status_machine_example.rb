shared_examples_for 'use asset status_machine' do  

  describe "constants" do 
    it "should have a hash" do 
      Asset::STATUS.should eq({"Operational" => 'operational', "Recieved" => 'recieved', "Spare" => 'spare', "Repair" => 'repair', "Assigned" => 'Assigned' })
    end
  end
  
  describe "scope assignable" do
    context "Status Assigned" do
      before do 
        @asset.update_attribute(:status, Asset::STATUS["Assigned"])
      end

      it "assignable should be blank" do 
        Asset.assignable.should be_blank
      end
    end

    context "Status Repair" do
      before do 
        @asset.update_attribute(:status, Asset::STATUS["Repair"])
      end

      it "assignable should be blank" do 
        Asset.assignable.should be_blank
      end
    end

    context "Status not in [Asset::STATUS['Assigned'], Asset::STATUS['Repair']]" do
      before do 
        @asset.update_attribute(:status, Asset::STATUS["Spare"])
      end

      it "should equal to [@asset]" do 
        Asset.assignable.should eq([@asset])
      end
    end
  end

  describe "#can_retire?" do 
    context "status is assigned" do 
      before do 
        @asset.update_attributes(status: Asset::STATUS["Assigned"])
      end

      it "should return false" do 
        @asset.can_retire?.should eq(false)
      end
    end

    context "status is assigned" do 
      it "should return false" do 
        @asset.can_retire?.should eq(true)
      end
    end
  end

  describe "#assignable?" do
    context "status assigned" do
      before do 
        @asset.update_attribute(:status, Asset::STATUS['Assigned'])
      end
      it "should return false" do
        @asset.assignable?.should be_false
      end
    end

    context "status repair" do
      before do 
        @asset.update_attribute(:status, Asset::STATUS['Repair'])
      end
      it "should return false" do
        @asset.assignable?.should be_false
      end
    end

    context "other status" do
      before do 
        @asset.update_attribute(:status, Asset::STATUS["Spare"])
      end
      it "should return true" do 
        @asset.assignable?.should be_true
      end
    end
  end

  describe "#mark_spare!" do 
    it "should update the status" do 
      @asset.mark_spare!
      @asset.status.should eq(Asset::STATUS["Spare"])
    end
    describe "should_receive methods" do 
      before do 
        @asset.stub(:update_attributes).with(:status => Asset::STATUS["Spare"])
      end
      it "should_receive update_attribute" do 
        @asset.should_receive(:update_attributes).with(:status => Asset::STATUS["Spare"])
        @asset.mark_spare!
      end
    end
  end

  describe "#assign!" do 
    it "should update the status as assigned" do 
      @asset.assign!
      @asset.status.should eq(Asset::STATUS["Assigned"])
    end
    
    describe "should_receive methods" do 
      before do 
        @asset.stub(:update_attributes).with(:status => Asset::STATUS["Assigned"])
      end
      it "should_receive update_attribute" do 
        @asset.should_receive(:update_attributes).with(:status => Asset::STATUS["Assigned"])
        @asset.assign!
      end
    end
  end


end