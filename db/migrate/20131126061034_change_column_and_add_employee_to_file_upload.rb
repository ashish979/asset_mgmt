class ChangeColumnAndAddEmployeeToFileUpload < ActiveRecord::Migration
  def up
    change_column :file_uploads, :description, :string
    add_column :file_uploads, :employee_id, :integer
    add_index :file_uploads, :employee_id
  end

  def down
    change_column :file_uploads, :description, :text
    remove_index :file_uploads, :employee_id
    remove_column :file_uploads, :employee_id
  end
end
