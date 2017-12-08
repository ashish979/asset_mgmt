class AddBrandToAssets < ActiveRecord::Migration
  def up
    add_column :assets, :brand, :string
  end

  def down
    remove_column :assets, :brand
  end
end
