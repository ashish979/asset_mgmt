class Comment
  module CommentNotification
    extend ActiveSupport::Concern

    included do
      after_create :send_comment_notifications, :if => "resource_type == 'Ticket'"
    end

    def send_comment_notifications
      TicketNotifier.delay.send_comment_notification(self, commenter)
    end
  end
end