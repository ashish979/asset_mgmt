module AssetPropertiesHelper
  def asset_properties?(p_group)
    p_group.asset_properties.where(asset_id: @asset.id).present? 
  end

  def group_asset_properties(p_group) 
    p_group.asset_properties.where(asset_id: @asset.id).includes(:property)
  end
end