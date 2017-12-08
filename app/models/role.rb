class Role < ActiveRecord::Base
  include Shared::RestrictiveDestroy
  
  has_many :employees_roles, dependent: :destroy
  has_many :employees, through: :employees_roles

  validates :name, presence: true, uniqueness: true
  validates :name, inclusion: { in: Employee::ROLES, message: "%{value} is not a valid role" }, allow_blank: true

end
