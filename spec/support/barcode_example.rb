shared_examples_for 'use barcode module' do  

  describe "before_save #create_barcode" do 

    context "barcode present" do 
      before do 
        @obj1 = described_class.new(barcode: "0001000001")
      end

      it "should not receive create_barcode" do 
        @obj1.should_not_receive(:create_barcode)
        @obj1.save(:validate => false)
      end
    end

    context "barcode not present" do 
      before do 
        @obj = described_class.new
        @obj.stub(:barcode_key).and_return("0002000002")
      end

      it "should_receive create_barcode" do 
        @obj.should_receive(:create_barcode).and_return("0002000002")
        @obj.save(:validate => false)
      end

      it "should return barcode" do 
        @obj.save(:validate => false)
        @obj.barcode.should eq("0002000002")
      end
    end
  end
  
  describe "#get_barcode" do 
    before do 
      require 'barby'
      require 'barby/barcode/code_128'
      require 'barby/outputter/svg_outputter'
    end
    
    context "should_receive methods" do 
      before do 
        @barcode = @asset.barcode
        Barby::Code128B.stub(:new).and_return(@barcode)
        Barby::SvgOutputter.stub(:new).and_return(@barcode)
        @barcode.stub(:to_svg).and_return(true)
        @barcode.stub(:xdim=).and_return(1)
        @barcode.stub(:height=).and_return(35)
      end

      it "Barby::Code128B should_receive new" do 
        Barby::Code128B.should_receive(:new).and_return(@asset.barcode)
        @asset.get_barcode
      end    

      it "barcode should_receive to_svg" do 
        @asset.barcode.should_receive(:to_svg).and_return(true)
        @asset.get_barcode
      end
    end

    it "should genrate barcode" do 
      bar_code = Barby::Code128B.new(@asset.barcode)
      outputter = Barby::SvgOutputter.new(bar_code)
      outputter.xdim,outputter.height = 1,35
      outputter.to_svg.should eq(@asset.get_barcode)
    end
  end

  describe "#barcode_key" do
    before do 
      @obj2 = described_class.new(id: 1, asset_type_id: 1)
      @obj2.save(:validate => false)
    end

    it "should genrate key using id and asset_type_id" do 
      @obj2.barcode_key.should eq("#{@obj2.asset_type_id.to_s.rjust(4,'0')}#{@obj2.id.to_s.rjust(6,'0')}")
    end
  end
end