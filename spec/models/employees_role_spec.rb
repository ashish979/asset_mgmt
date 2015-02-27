require 'spec_helper'

describe EmployeesRole do 
  
  before(:each) do 
    @role1 = Role.create(name: "employee")
    @role2 = Role.create(name: Employee::ROLES[1])
    @company = Company.create(name: "Vinsol", email: 'test@vinsol.com')
    @employee = Employee.create(email: "ashutosh.tiwari@vinsol.com", name: "Ashutosh", employee_id: 2, company_id: @company.id)
    @role = Role.new(name: Employee::ROLES.first)

    @employee.roles << @role
    @employees_role = @employee.employees_roles
  end

  describe 'validation' do 
    it { should validate_uniqueness_of(:role_id).scoped_to(:employee_id) }
  end
  
  describe "association" do 
    it { should belong_to(:employee) }
    it { should belong_to(:role) }
  end
end