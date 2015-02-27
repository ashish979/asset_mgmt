#run after deploy but before migration, migration will remove type column
require File.expand_path(File.join(File.dirname(__FILE__), '../config', 'environment'))

types = Asset.unscoped.pluck(:type).uniq
comp_id = Company.first.id
types.each do |t|
  AssetType.create(name: t, company_id: comp_id)
end

Asset.unscoped.all.each do |asset|
  asset_type = AssetType.where(name: asset.type).first
  p asset if asset_type.blank?
  asset.update_attribute(:asset_type_id, asset_type.id)
end