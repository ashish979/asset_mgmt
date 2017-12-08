class AssignmentNotifier < ActionMailer::Base
  
  def assignment_notification(employee, asset, status, current_admin)
    @employee, @asset, @status, @admin = employee, asset, status, current_admin
    from = "#{@admin.name} <#{@admin.email}>"
    subject = "[#{@employee.company_name}]" + (@status ? " #{@asset.name} is assigned to you." : " Thanks for returning #{@asset.name}.")
    mail(:to => @employee.email, :from =>  from, :cc => @employee.company.admins.pluck(:email), :subject => subject)
  end
end