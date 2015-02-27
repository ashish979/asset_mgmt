class RemoveColumnTypeFromAssets < ActiveRecord::Migration
  def up
    remove_column :assets, :type
  end

  def down
    add_column :assets, :type, :string
  end
end
