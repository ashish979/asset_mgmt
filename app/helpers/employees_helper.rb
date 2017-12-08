module EmployeesHelper

  def show_history employee
    unless(employee.assignments.blank?)
      link_to "History", history_employee_path(employee), :class => 'btn'
    end
  end
  
  def show_disable_option emp
    unless emp.deleted?
      link_to 'Disable', disable_employee_path(emp), :method => :put, :class => 'btn btn-medium btn-danger', :disabled => emp == current_employee, :data => { :confirm => t('.confirm', :default => t("helpers.links.confirm", :default => 'Are you sure?')) }
    else
      link_to 'Enable', enable_employee_path(emp), :method => :put, :class => 'btn btn-medium btn-primary'
    end
  end

  def current_employee_or_employee_disabled?(employee)
    employee.id == current_employee.id || employee.disabled?
  end
  
end
