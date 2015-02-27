class CreateAssetTypePropertyGroups < ActiveRecord::Migration
  def change
    create_table :asset_type_property_groups do |t|
      t.references :asset_type
      t.references :property_group
    end
  end
end
