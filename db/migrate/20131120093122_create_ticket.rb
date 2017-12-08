class CreateTicket < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.references :company, :null => false
      t.references :ticket_type, :null => false
      t.references :employee, :null => false
      t.references :asset
      t.integer :state, :default => 1
      t.text :description
      
      t.timestamps
    end
    add_index :tickets, :company_id
    add_index :tickets, :ticket_type_id
    add_index :tickets, :employee_id
    add_index :tickets, :state
  end
end
