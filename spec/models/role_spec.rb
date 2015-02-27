require 'spec_helper'

describe Role do 

  it_should 'use restrictive destroy'
  
  before(:each) do 
    @role1 = Role.create(name: "employee")
    @role = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: 'test@vinsol.com')
    @employee = Employee.create(email: "ashutosh.tiwari@vinsol.com", name: "Ashutosh", employee_id: 2, company_id: @company.id)

    @role = Role.new(name: Employee::ROLES.first)
  end

  describe 'validation' do 
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should ensure_inclusion_of(:name).in_array(Employee::ROLES).with_low_message("%{value} is not a valid role") }
  end
  
  describe "association" do 
    it { should have_many(:employees_roles) }
    it { should have_many(:employees).through(:employees_roles) }
  end
end