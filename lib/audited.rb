module Audited

  class << self
    attr_accessor :ignored_attributes, :current_employee_method, :audit_class
  end

  @ignored_attributes = %w(lock_version created_at updated_at created_on updated_on)

  @current_employee_method = :current_employee
end
