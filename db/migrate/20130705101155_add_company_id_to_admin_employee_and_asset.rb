class AddCompanyIdToAdminEmployeeAndAsset < ActiveRecord::Migration
  def change
  	add_reference :admins, :company, index: true
  	add_reference :employees, :company, index: true
  	add_reference :assets, :company, index: true
  	add_reference :tags, :company, index: true
  end
end
