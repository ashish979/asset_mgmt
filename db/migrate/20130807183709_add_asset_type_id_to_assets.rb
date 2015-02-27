class AddAssetTypeIdToAssets < ActiveRecord::Migration
  def up
    add_column :assets, :asset_type_id, :integer
  end

  def down
    remove_column :assets, :asset_type_id
  end
end
