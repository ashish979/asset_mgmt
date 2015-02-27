require 'spec_helper'

describe Company do
  
  it_should 'use restrictive destroy'

  before do 
    @role = Role.create!(name: Employee::ROLES[1])
    @role1 = Role.create!(name: Employee::ROLES[2])
    @company = Company.create!(name: "Vinsol", email: "hr@vinsol.com")
    Company.any_instance.stub(:firstname).and_return(@company.name)
    @employee = Employee.first
  end
  
  describe "validation" do 
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value('test@example.com').for(:email ) }
    it { should allow_value('test@example.co.in').for(:email ) }
    it { should_not allow_value('test@example').for(:email ) }
    it { should allow_value('http://www.vinsol.com').for(:website) }
    it { should allow_value('https://www.vinsol.com').for(:website) }
    it { should_not allow_value('vinsol.com').for(:website) }
  end

  describe "associations" do
    it { should have_many(:assets) }
    it { should have_many(:employees) }
    it { should have_many(:tags) }
    it { should have_many(:properties) }
    it { should have_many(:property_groups) }
    it { should have_many(:ticket_types) }
    it { should have_many(:tickets) }
    it { should have_many(:associated_audits).class_name(Audited.audit_class.name) }
    it { should have_many(:admins).class_name(Employee) }
  end

  describe "validation for website" do
    context "website present" do 
      context "website already taken" do 
        before do 
          @company.update_attribute(:website, "http://www.vinsol.com")
        end
        it "should have error on website" do 
          Company.new(name: "Test", email: "test@vinsol.com", website: "http://www.vinsol.com").should have(1).error_on(:website)
        end
      end
      context "website is not taken" do 
        it "should_not have error on website" do 
          Company.new(name: "Test", email: "test@vinsol.com", website: "http://www.vinsol.com").should have(0).error_on(:website)
        end
      end
    end
    context "website not present" do 
      it "should save the record" do 
        @company.save.should eq(true)
      end

      it "should_not have error on website" do 
        Company.new(name: "Test", email: "test@vinsol.com").should have(0).error_on(:website)
      end
    end
  end

  describe "#enabled?" do 
    context "company enabled" do 
      it "should return true" do 
        @company.enabled?.should eq(true)
      end
    end

    context "company disabled" do 
      before do 
        @company.update_attribute(:status, false)
      end
      it "should return false" do 
        @company.enabled?.should eq(false)
      end
    end
  end

  describe "#disabled?" do 
    context "company enabled" do 
      it "should return false" do 
        @company.disabled?.should eq(false)
      end
    end

    context "company disabled" do 
      before do 
        @company.update_attribute(:status, false)
      end
      it "should return true" do 
        @company.disabled?.should eq(true)
      end
    end
  end

  describe "#firstname" do 
    it "should return first name" do 
      @company.firstname.should eq('Vinsol')
    end
  end

  describe "associations admins" do 

    it "should return all admins" do 
      @company.admins.count.should eq(1)
    end

    it "should equal to employee" do 
      @company.admins.first.should eq(Employee.first)
    end
  end

  describe "#create_default_admin" do 
    before do 
      Employee.delete_all
      @company1 = Company.create!(name: 'Testing', email: 'testing@vin.com')
    end

    it "Employee should be created" do 
      Employee.count.should eq(1)
    end

    it "should create a default_admin" do 
      Employee.first.is_admin.should eq(true)
    end

    it "should create admin with name of company" do 
      Employee.first.name.should eq('Testing')
    end

    it "should create admin with Email of company" do 
      Employee.first.email.should eq('testing@vin.com')
    end

    it "should create admin with employee_id 1" do 
      Employee.first.employee_id.should eq(1)
    end

    it "should assign admin role to employee" do 
      Employee.first.has_role?(:admin)
    end
  end

  describe "has_permalink:firstname" do 
    it "should define a before_filter generate_permalink" do 
      @company.should_receive(:generate_permalink)
      @company.save
    end
  end

  describe 'auto_strip_whitespace' do
    before do 
      @company1 = Company.new(:name => '    Test     ', email: 'test@test.com')  
    end

    it "valid? should return false if it find name is present in db after strip" do
      company = Company.new(:name => '    Vinsol     ', email: 'test@test.com')
      company.valid?.should eq(false) 
    end  

    it 'should strip white space from start and end of company name and then validate it' do
      @company1.valid?
      @company1.name.should eq('Test')
    end
  end

end
