class AddCommenterToHistoryComments < ActiveRecord::Migration
  def up
    add_column :history_comments, :commenter_id, :integer
  end

  def down
    remove_column :history_comments, :commenter_id
  end
end
