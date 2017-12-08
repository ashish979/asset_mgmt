class CreatePropertyGroups < ActiveRecord::Migration
  def change
    create_table :property_groups do |t|
      t.string :name
      t.references :company
      
      t.timestamps
    end
  end
end
