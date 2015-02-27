class Property < ActiveRecord::Base
  has_associated_audits  
  auto_strip_attributes :name
  
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :property_group_id }
  validates :property_group, presence: true 

  belongs_to :company
  has_many :asset_properties, dependent: :destroy
  has_many :assets, through: :asset_properties
  belongs_to :property_group
  
  after_create :update_asset_properties

  private
    def update_asset_properties
      ids = property_group.asset_types.pluck(:id)
      assets = Asset.where(asset_type_id: ids, company_id: property_group.company_id)
      assets.each do |asset|
        asset.properties << self 
      end
    end
  
end
