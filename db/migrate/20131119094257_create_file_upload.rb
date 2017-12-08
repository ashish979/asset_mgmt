class CreateFileUpload < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|
      t.attachment :file
      t.text :description
      t.references :asset
    end
    add_index :file_uploads, :asset_id
  end
end
