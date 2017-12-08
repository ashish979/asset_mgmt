require 'soft_deletion'

class Employee < ActiveRecord::Base
  # FIXME this devise method will move into concerns employee/devisable.rb, facing some issue, need to look into it and then fix.
  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable

  include Devisable
  include ManageRole
  
  has_soft_deletion :default_scope => true
  ROLES = %w[super_admin admin employee]

  validates :email, format: { :with => EMAIL_REGEX }, allow_blank: true
  validates :employee_id, :presence => { message: 'ID cannot be blank'}, uniqueness: { scope: :company_id, message: "ID has already being taken" }
  validates :employee_id, numericality: { :only_integer => true, :greater_than => 0, :message => "ID must be positive"}, allow_blank: true
  validates :name, presence: true
    
  has_many :employees_roles, dependent: :destroy
  has_many :roles, through: :employees_roles
  has_many :assignments
  has_many :assets, through: :active_assignments
  has_many :comments, :foreign_key => 'commenter_id'
  has_many :returned_assignments, -> { where.not(date_returned: nil) }, class_name: 'Assignment'
  has_many :active_assignments, -> { where(date_returned: nil).order("asset_employee_mappings.date_issued desc") }, class_name: 'Assignment'
  has_many :tickets
  has_many :file_uploads
  belongs_to :company

  scope :enabled, lambda { |company|  Employee.where(company_id: company) }
  scope :disabled, lambda { |company|  unscoped.where.not(deleted_at: nil).where(company_id: company.id) } 

  delegate :name, to: :company, prefix: true

  alias_attribute :admin, :is_admin
  before_create :assign_default_role

  def can_be_disabled?
    assignments.all? { |a| a.returned? }
  end
  
  def enabled?
    !deleted_at?
  end        

  def disabled?
    !enabled?
  end

  def has_role?(role_sym)
    roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end

  def has_any_role?
    roles.any? { |r| Employee::ROLES.include?(r.name)}
  end
  
  private
    def assign_default_role
      self.roles << Role.where(name: "employee").first
    end

end