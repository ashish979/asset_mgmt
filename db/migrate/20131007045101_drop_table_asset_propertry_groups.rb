class DropTableAssetPropertryGroups < ActiveRecord::Migration
  def up
    drop_table :asset_property_groups
  end  
  
  def down
    create_table :asset_property_groups do |t|
      t.references :asset
      t.references :property_group
    end
  end
end
