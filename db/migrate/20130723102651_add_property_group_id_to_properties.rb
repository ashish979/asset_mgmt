class AddPropertyGroupIdToProperties < ActiveRecord::Migration
  def change
    add_reference :properties, :property_group, index: true
  end
end
