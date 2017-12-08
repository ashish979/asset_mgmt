class AddHistoryToAssets < ActiveRecord::Migration
  def change
    add_column :assets, :history, :text
  end
end
