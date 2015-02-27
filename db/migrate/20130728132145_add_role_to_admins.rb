class AddRoleToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :role, :string, default: 'admin'
  end
end
