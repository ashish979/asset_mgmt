class Employee
  module ManageRole
    extend ActiveSupport::Concern

    def manage_admin_role!
      role_id = Role.where(name: "admin").first.id
      if has_role?(:admin)
        remove_admin_role(role_id)
      else
        add_admin_role(role_id)
      end
      reload
    end

    def remove_admin_role(role_id)
      employees_roles.where(role_id: role_id).destroy_all
    end

    def add_admin_role(role_id)
      employees_roles.create(role_id: role_id)
    end
  
  end
end