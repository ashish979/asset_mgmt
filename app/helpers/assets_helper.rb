module AssetsHelper
  def show_name type
    return AssetType.where(id: params[:asset_type_id]).first.try(:name).try(:pluralize) if params[:asset_type_id].present?
    return "Retired Assets" if type == "retired"
    "Assets"
  end

  def show_status asset
    if(asset.status == "Assigned")
      "Assigned to #{link_to asset.assigned_employee.name, asset.assigned_employee}".html_safe
    else
      asset.status.capitalize
    end
  end

  def show_status_field f
    if @asset.status == "Assigned"
      "Assigned"
    else
      if @asset.new_record?
        f.select(:status, options_for_select(Asset::STATUS.to_a - [["Recieved", "recieved"], ["Assigned", "Assigned"]], @asset.status), :include_blank => "- Select -")
      else
        f.select(:status, options_for_select(Asset::STATUS.to_a - [["Assigned", "Assigned"]], @asset.status), :include_blank => "- Select -")
      end
    end
  end

  def show_category asset, f
    unless asset.new_record?
      asset.asset_type.try(:name) || 'No Type'
    else
      return @asset_type.try(:name) if params[:asset_type_id]
      asset_type_id = params[:asset][:asset_type_id] if params[:asset]
      f.select(:asset_type_id, options_for_select(current_employee.company.asset_types.collect{|asset_type| [asset_type.name, asset_type.id] }, asset_type_id), :include_blank => "- Select -") 
    end
  end

  def selected_asset_type
    return params[:asset][:asset_type_id] if params[:asset] && params[:asset][:asset_type_id]
    return @asset_type.try(:id) if @asset_type
  end


  def show_property_groups
    if @asset.asset_property_groups.present?
      current_employee.company.property_groups.where("id not in (?)",@asset.asset_property_groups.pluck(:property_group_id)).collect { |pg| [pg.name, pg.id] }
    else
      current_employee.company.property_groups.collect { |pg| [pg.name, pg.id] }
    end
  end

  def auditor_name(audit)
    admin = audit.admin.kind_of?(Employee) ? audit.admin : Employee.unscoped.where(id: audit.admin).first
    link_to admin.name, admin if admin
  end

  def sorting_condition(attr_name, conditions)
    if conditions.present?
      condition = conditions.split.include?('asc') ? 'desc' : 'asc'
      return attr_name + " IS NULL, " + attr_name + " " + condition if attr_name == "employees.name"
      return attr_name + " " + condition unless attr_name == "employees.name"
    else
      if attr_name == "employees.name"
        return attr_name + " IS NULL, " + attr_name + " asc" 
      else
        return attr_name + " asc" if attr_name != "id"
        return attr_name + " desc" if attr_name == "id"
      end
    end
  end

  def show_asset_name(history)
    return link_to history.asset.name, [history.asset.asset_type, history.asset] if history.asset.present?
    asset = Asset.unscoped.where(id: history.asset_id).includes(:asset_type).first
    return link_to asset.name, [asset.asset_type, asset] if asset.present?
  end

  def show_currency_symbol
    CURRENCY.collect do |currency|
      if currency[1] == '&#8377;'
        ['<span style="font-family:rupee;font-size:16px">&#8377;</span>'.html_safe, currency[1]]
      else
        [currency[1].html_safe, currency[1]] 
      end
    end
  end
  
  def uploaded_files 
    @asset.file_uploads.includes(:uploader)
  end

  def filter_paperclip_error(obj)
    msg = obj.errors.messages
    if msg[:"file_uploads.file"] && msg[:"file_uploads.file"].size == 1 && msg[:"file_uploads.file"] == ["can't be blank"]
      obj.errors.messages
    else
      obj.errors.messages.except!(:"file_uploads.file")
    end
  end


end

