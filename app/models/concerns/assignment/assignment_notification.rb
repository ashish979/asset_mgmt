class Assignment
  module AssignmentNotification
    extend ActiveSupport::Concern

    included do
      after_save :send_notification
    end

    def send_notification
      current_employee = Thread.current[:audited_admin]
      status = !returned?
      AssignmentNotifier.delay.assignment_notification(employee, asset, status, current_employee)
    end
  end
end