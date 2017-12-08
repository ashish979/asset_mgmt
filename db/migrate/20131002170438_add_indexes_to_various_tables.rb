class AddIndexesToVariousTables < ActiveRecord::Migration
  def self.up
    add_index :employees, :employee_id
    add_index :tags, :name
    add_index :assets, [:barcode, :purchase_date, :status]
  end

  def self.down
    remove_index :employees, :employee_id
    remove_index :tags, :name
    remove_index :assets, [:barcode, :purchase_date, :status]
  end

end
