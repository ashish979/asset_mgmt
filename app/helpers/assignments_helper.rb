module AssignmentsHelper

    
  def asset_name f
    "#{f.hidden_field :asset_id} #{@assignment.asset.name}".html_safe
  end
  
  def fetch_assets
    current_employee.company.assets.assignable.collect { |asset| ["#{asset.display_name}", asset.id] }
  end 

  def select_category
    current_employee.company.asset_types.collect{|asset_type| [asset_type.name, asset_type.id]}
  end
  
  def selected_category
    return params[:category] if params[:category]
    return @asset_type.try(:id) if @asset_type
  end

  def show_selected_asset_name
    return @asset.name if @asset
    @asset = Asset.where(id: params[:asset_id]).first.name
  end

  def show_asset_type_name
    return @asset_type.name if @asset_type
    @asset_type = AssetType.where(id: params[:asset_type_id]).first.name
  end
  
end
