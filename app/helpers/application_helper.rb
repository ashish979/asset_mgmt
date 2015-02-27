module ApplicationHelper
  include Devise::TestHelpers
  
  def date_to_string date_obj
    date_obj.blank? ? "" : date_obj.strftime("%d %b %Y")
  end
  
  def class_name controller, action, type=nil
    if params[:asset_type_id]
      "highlighted" if params[:controller] == controller && params[:action] == action && (params[:asset_type_id].to_i == type)
    elsif type 
      "highlighted" if params[:controller] == controller && params[:action] == action && (params[:type].to_i == type || params[:type] == type)
    else
      "highlighted" if params[:controller] == controller && params[:action] == action && !params[:type]
    end
  end

  def tag_class_name controller, action
    "activeTab" if params[:controller] == controller && params[:action] == action
  end
  
  def get_all_employees
    current_employee.company.employees.order("name asc").collect { |emp| [emp.name, emp.id] }
  end 

  def mark_required(object, attribute)
    "*" if object.class.validators_on(attribute).map(&:class).include? ActiveRecord::Validations::PresenceValidator
  end

  # def page_entries_info(collection, options = {})
  #   if collection.total_pages < 2
  #     if collection.size < 50
  #       %{%d of %d} % [
  #       collection.offset + collection.length,
  #       collection.offset + collection.length
  #     ]
  #     else
  #     %{%d-%d of %d} % [
  #       collection.offset + 1,
  #       collection.offset + collection.length,
  #       collection.total_entries
  #     ]
  #     end
  #   else
  #     %{%d-%d of %d} % [
  #       collection.offset + 1,
  #       collection.offset + collection.length,
  #       collection.total_entries
  #     ]
  #   end
  # end

  def ist(time)
    time.in_time_zone(TZInfo::Timezone.get('Asia/Kolkata'))
  end

  def set_resource_class
    params[:resource_class].present? ? params[:resource_class] : params[:controller] 
  end
  
end
