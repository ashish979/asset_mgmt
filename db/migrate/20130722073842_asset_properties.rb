class AssetProperties < ActiveRecord::Migration
  def change
    create_table :asset_properties do |t|
      t.string :value
      t.references :property
      t.references :asset
      t.references :property_group
    
      t.timestamps
    end
  end
end
