class AddBarcodeToAssets < ActiveRecord::Migration
  def up
    add_column :assets, :barcode, :string
  end

  def down
    remove_column :assets, :barcode
  end
end
