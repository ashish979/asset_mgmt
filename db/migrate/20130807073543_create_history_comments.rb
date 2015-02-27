class CreateHistoryComments < ActiveRecord::Migration
  def change
    create_table :history_comments do |t|
      t.references :asset
      t.text :comment

      t.timestamps
    end
  end
end
