class Ability
  include CanCan::Ability

  def initialize(employee)
    employee ||= Employee.new    
    
    if employee.has_role?(:super_admin)
      can :manage, Company
    elsif employee.has_role?(:admin)
      can :manage, :all
      cannot :manage, Company
    elsif employee.has_role?(:employee)
      can :manage, Ticket, employee: {id: employee.id}
      can [:show], Asset, status: Asset::STATUS["Assigned"], active_assigned_employee: employee
      can [:create, :read], Comment, resource_type: "Ticket", resource: {employee_id: employee.id}
    end
    
  end
end
