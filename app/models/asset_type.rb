class AssetType < ActiveRecord::Base
  include RestrictiveDestroy
  
  belongs_to :company 
  has_many :asset_type_property_groups, dependent: :destroy
  has_many :property_groups, through: :asset_type_property_groups
  has_many :assets
  
  validates :name, presence: true, uniqueness: { scope: :company_id }
  accepts_nested_attributes_for :asset_type_property_groups, allow_destroy: true

end
