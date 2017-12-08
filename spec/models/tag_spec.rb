require 'spec_helper'

describe Tag do 
  before(:each) do
    @tag = Tag.new(name: "Apple")
  end
    
    describe "validation" do 
    it { should validate_presence_of(:name) }
  end

  describe "association" do 
    it { should have_and_belong_to_many(:assets) }
    it { should belong_to(:company) }
  end
    
end 
