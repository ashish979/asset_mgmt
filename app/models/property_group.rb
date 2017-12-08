class PropertyGroup < ActiveRecord::Base
  validates :name, presence: true, uniqueness: { case_sensitive: false, scope: :company_id}
  auto_strip_attributes :name
  
  belongs_to :company
  has_many :properties, dependent: :destroy
  has_many :assets, -> { group "asset_id" }, through: :asset_properties
  has_many :asset_properties
  has_many :asset_type_property_groups, dependent: :destroy
  has_many :asset_types, through: :asset_type_property_groups

end
