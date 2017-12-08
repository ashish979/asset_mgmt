class AssetTypePropertyGroup < ActiveRecord::Base
  include ManageProperties  
  
  belongs_to :asset_type
  belongs_to :property_group
  
end
