shared_examples_for 'use commentable module' do
  describe "associations" do 
    it { should have_many(:comments) }
  end
end