module AssetTypeHelper

  def attr_checked?(form_obj)
    return true if form_obj.object.persisted?
    if params[:asset_type] && params[:asset_type][:asset_type_property_groups_attributes]
      params[:asset_type][:asset_type_property_groups_attributes].each do |k, v|
        return v["_destroy"] == "0" if form_obj.object.property_group_id == v["property_group_id"].to_i
      end  
    end
  end
  
end