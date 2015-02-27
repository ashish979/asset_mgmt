class EmployeesRole < ActiveRecord::Base

  belongs_to :role 
  belongs_to :employee

  validates :role_id, uniqueness: {scope: :employee_id}
  
  #send email if employee role has been made admin
  #FIX_ME: Need to send at role change?? if yes then will use Notification mailer to send various type of notifiaction move assignment_notification to inside new notification.
  # after_create :send_role_change_notifiaction, if: "employee.has_role?(:admin)"

  # def send_role_change_notifiaction
  #   current_employee = Thread.current[:audited_admin]
  #   employee.delay.change_roles_notification(self, current_employee)
  # end

end