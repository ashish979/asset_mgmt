class CreateAssetPropertyGroups < ActiveRecord::Migration
  def change
    create_table :asset_property_groups do |t|
      t.references :asset
      t.references :property_group
    end
  end
end
