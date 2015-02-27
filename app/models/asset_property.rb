class AssetProperty < ActiveRecord::Base
  audited only: [:value], associated_with: :property, on: [:update, :destroy]

  validates :property, :asset, :property_group, presence: true
  validates :asset, uniqueness: { scope: [:property_id, :property_group_id], message: "There is already a record with same property and property group for this asset" }, allow_blank: true

  belongs_to :property
  belongs_to :asset
  belongs_to :property_group

  before_validation :assign_property_group, :unless => :property_group_id?

  def assign_property_group
    self.property_group_id = property.property_group_id
  end
  
end
