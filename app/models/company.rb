class Company < ActiveRecord::Base
  include Shared::RestrictiveDestroy

  has_associated_audits
  auto_strip_attributes :name

  validates :name, :email, presence: true
  validates :name, :email, uniqueness: true, allow_blank: true
  validates :website, uniqueness: true, :if => :website?
  validates :email, :format => { :with => EMAIL_REGEX }, :allow_blank => true
  validates :website, :format => { :with => URI::regexp(%w(http https)) }, :allow_blank => true

  has_many :assets
  has_many :employees
  has_many :tags
  has_many :properties
  has_many :property_groups
  has_many :asset_types
  has_many :ticket_types
  has_many :tickets
  has_many :admins, -> { joins(:roles).where(roles: {name: "admin"})}, class_name: "Employee"

  after_create :create_default_admin

  has_permalink :firstname, :unique => true
  
  def enabled?
    status?
  end

  def disabled?
    !enabled?
  end

  def firstname
    name.split()[0] if name
  end

  private
  
    def create_default_admin
      employee = employees.new(name: name, email: email, employee_id: 1, is_admin: true)
      employee.roles = [Role.where(name: "admin").first]
      employee.save
    end

end
