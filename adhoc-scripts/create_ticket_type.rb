require File.expand_path(File.join(File.dirname(__FILE__), '../config', 'environment'))

companies = Company.all
ticket_type = ['New Hardware', 'Upgrade Hardware', 'Trouble Ticket']
companies.each do |comp|
  ticket_type.each do |type|  
    TicketType.create(name: type, company_id: comp.id)
  end
end