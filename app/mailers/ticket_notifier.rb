class TicketNotifier < ActionMailer::Base
  default :from => "it@payu.in"

  def ticket_creation_notification(ticket)
    @ticket = ticket
    cc = @ticket.company.admins.where.not(id: @ticket.employee_id).pluck(:email)
    to = "#{@ticket.employee_name} <#{@ticket.employee_email}>"
    subject = "[#{@ticket.company_name}] New ticket notification"
    mail(:to => to, :cc => cc, :subject => subject)
  end

  def send_comment_notification(comment, commenter)
    @comment, @commenter = comment, commenter
    from = "#{@commenter.name} <#{@commenter.email}>"
    subject = "[#{@commenter.company_name}] #{@commenter.name.titleize} has commented on ticket ##{@comment.resource.id}"
    if @commenter.id == @comment.resource.employee_id
      to = @commenter.company.admins.pluck(:email)
    else
      to = @comment.resource.employee_email
    end
    mail(:to => to, :from => from, :subject => subject)
  end

end