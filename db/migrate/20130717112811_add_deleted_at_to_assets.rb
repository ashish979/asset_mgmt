class AddDeletedAtToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :deleted_at, :datetime, default: nil
    add_index :assets, :deleted_at
  end
end
