class RemoveHistoryFromAssets < ActiveRecord::Migration
  def up
    remove_column :assets, :history
  end

  def down
    add_column :assets, :history
  end
end
