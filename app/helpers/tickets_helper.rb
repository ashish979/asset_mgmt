module TicketsHelper
  
  def show_change_state_link(ticket)
    if ticket.open?
      link_to "Close", change_state_ticket_path(ticket), method: :put, data: {confirm: "Are you sure, you want to close this ticket?"}, :class => "btn btn-danger changeTicketState" 
    else
      link_to "Reopen", change_state_ticket_path(ticket), method: :put, data: {confirm: "Are you sure, you want to reopen this ticket?"}, :class => "btn btn-primary changeTicketState"
    end
  end

  def show_ticket_type(ticket, f)
    if (current_employee.has_role?(:admin) && current_employee.company.assets.present?) || current_employee.active_assignments.present?
      f.select(:ticket_type_id, options_for_select(TicketType.all.collect{|t| [t.name, t.id] }, @ticket.ticket_type_id), :include_blank => "- Select -") 
    else
      f.select(:ticket_type_id, options_for_select([["New Hardware", TicketType.where(name: "New Hardware").first.id]]))
    end
  end

  def show_assets_for_tickets(f)
    if current_employee.has_role?(:admin)
      f.select(:asset_id, options_for_select(current_employee.company.assets.collect{|asset| [asset.display_name, asset.id] }, @ticket.asset_id), :include_blank => "- Select -")    
    else
      f.select(:asset_id, options_for_select(current_employee.assets.collect{|asset| [asset.display_name, asset.id] }, @ticket.asset_id), :include_blank => "- Select -")    
    end      
  end

  def show_ticket_asset_name(ticket)
    return link_to ticket.asset.display_name, [ticket.asset.asset_type, ticket.asset] if ticket.asset.present?
    asset = Asset.unscoped.where(id: ticket.asset_id).first
    if current_employee.has_role?(:admin)
      link_to asset.display_name, [asset.asset_type, asset] 
    else
      asset.display_name
    end    
  end
  
  def show_ticket_employee_name(ticket)
    return link_to ticket.employee_name, ticket.employee if ticket.employee.present?
    employee = Employee.unscoped.where(id: ticket.employee_id).first
    link_to employee.name, employee
  end
end