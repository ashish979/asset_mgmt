class Asset < ActiveRecord::Base
  include Barcode
  include Taggable
  include ManagePropertyGroups
  include StatusMachine
  include Shared::RestrictiveDestroy
  include Commentable

  audited only: [:name, :status, :deleted_at, :vendor, :brand, :serial_number, :purchase_date, :description,:cost,:additional_info], associated_with: :company, on: [:update, :destroy]
  default_scope { where(deleted_at: nil) }

  validates :name, :status, :cost, :asset_type_id, :vendor, :purchase_date, presence: true
  validates :cost, numericality: true, length: {:maximum=> 10}, allow_blank: true 
  validates :serial_number, presence: true, uniqueness: true
  validates :brand, presence: true, on: :create
  validates :purchase_date, :date => { :before => Proc.new { Time.current } }, allow_blank: true  
  
  has_many :file_uploads
  has_many :assignments
  has_many :employees, :through => :assignments
  has_many :asset_properties, dependent: :destroy
  has_many :properties, through: :asset_properties
  has_many :property_groups, -> { group "property_group_id" }, through: :asset_properties 
  has_many :active_assignments, -> { where(date_returned: nil) }, class_name: 'Assignment'
  has_many :tickets, lambda{ joins(:ticket_type).where.not(ticket_types: {name: "New Hardware"}) }, class_name: 'Ticket'
  
  belongs_to :company
  belongs_to :asset_type

  accepts_nested_attributes_for :file_uploads, :allow_destroy => true, reject_if: proc { |attributes| attributes['file'].blank? && attributes['description'].blank?}
  
  scope :retired_assets, lambda { |company| unscoped.where.not(deleted_at: nil).where(company_id: company.id) }

  before_update :restrict_update, :if => "retired?"

  def self.search(asset, status, category, from, to, employee)
    conditions = self.search_conditions(asset, status, category, from, to)
    result = self.where(conditions).includes(:asset_type)
    if employee.present? 
      result = result.joins(assignments: :employee).where("asset_employee_mappings.date_returned is NULL")
      if employee.kind_of?(Integer)
        result = result.where(employees: {employee_id: employee}) 
      else
        result = result.where(employees: {name: employee}) 
      end
    end
    result
  end 
  
  # Will return an active relation of employees to whome any asset is asssigned  
  def assigned_employee
    assignments.last.try(:employee) 
  end

  def active_assigned_employee
    active_assignments.last.try(:employee) 
  end
  
  def retired?
    deleted_at.present?
  end

  def display_name
    "#{self.id}-#{self.name}"
  end

  def has_tickets?
    tickets.present?
  end

  private    
    
    def restrict_update
      return false unless changes.keys.include?("deleted_at")
    end

    def self.search_conditions(asset, status, category, from, to)
      conditions = ['1']
      if asset.present?
        conditions[0] += " AND (assets.name like ? OR assets.serial_number like ?)"
        conditions.push("%#{asset}%").push("%#{asset}%")
      end
      if category.present?
        conditions[0] += " AND assets.asset_type_id = ?" 
        conditions << category
      end
      if status.present?
        conditions[0] += " AND assets.status = ?"
        conditions << status
      end
      if to.present?
        conditions[0] += " AND DATE(purchase_date) <= ?" 
        conditions << to.to_date
      end
      if from.present?
        conditions[0] += " AND DATE(purchase_date) >= ?"
        conditions << from.to_date
      end
      conditions 
    end

end
