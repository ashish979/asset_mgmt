class CreateAssetType < ActiveRecord::Migration
  def change
    create_table :asset_types do |t|
      t.string :name
      t.references :company
      
      t.timestamps
    end
  end
end
