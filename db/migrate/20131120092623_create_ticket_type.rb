class CreateTicketType < ActiveRecord::Migration
  def change
    create_table :ticket_types do |t|
      t.string :name
      t.references :company, :null => false
      
      t.timestamps
    end
    add_index :ticket_types, :company_id
  end
end
