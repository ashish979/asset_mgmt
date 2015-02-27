class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :name
      t.references :company
      
      t.timestamps
    end
  end
end