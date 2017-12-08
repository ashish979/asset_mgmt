class CreateEmployeesRoles < ActiveRecord::Migration
  def change
    create_table :employees_roles do |t|
      t.references :role, :null => false
      t.references :employee, :null => false
    end
    add_index :employees_roles, [:employee_id, :role_id]
  end
end
