module TicketNotification
  extend ActiveSupport::Concern

  included do
    after_create :send_ticket_creation_mail
  end

  def send_ticket_creation_mail
    TicketNotifier.delay.ticket_creation_notification(self)
  end
end
