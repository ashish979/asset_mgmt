class Ticket < ActiveRecord::Base
  include Shared::RestrictiveDestroy
  include Commentable
  include TicketNotification

  STATE = { open: 1, closed: 2 }
  has_many :comments, :as => :resource, dependent: :destroy
 
  belongs_to :employee
  belongs_to :ticket_type
  belongs_to :company
  belongs_to :asset

  validates :employee, :description, :ticket_type, presence: true
  validates :asset, presence: true, :if => "!new_hardware?"
  validates :asset, absence: true, :if => "new_hardware?"

  delegate :name, to: :company, prefix: true
  delegate :name, :email, to: :employee, prefix: true
  delegate :name, to: :ticket_type, prefix: true
  delegate :new_hardware?, to: :ticket_type, allow_nil: true

  attr_readonly :description

  validate :validate_asset, :if => "!new_hardware?"

  def open?
  	state == STATE[:open]
  end

  def change_state!
  	update_column(:state, new_state)
  end

  def title
    "Ticket ##{id}"
  end

  def self.search(category, state, query, current_employee)
    where(search_conditions(category, state, query, current_employee))
  end

  private
    def new_state
      open? ? STATE[:closed] : STATE[:open]
    end

    def validate_asset
      if !company.assets.exists?(id: asset_id)
        errors.add(:base, "Asset does not exists.")
      elsif !employee.has_role?(:admin) && !employee.active_assignments.exists?(asset_id: asset_id)
        errors.add(:base, "#{asset.name} is currently not assigned to you.") 
      end
    end

    def self.search_conditions(category, state, query, current_employee)
      @conditions, asset_ids, emp_ids = ['1'], [], []
      if category.present?
        if(category == "Id")
          add_conditions(" AND tickets.id = ?" , query)
        elsif(category == "Asset")
          add_conditions(" AND tickets.asset_id in (?)", get_unscoped_asset_ids(query))
        elsif(category == "Employee")
          add_conditions(" AND tickets.employee_id in (?)", get_unscoped_employee_ids(query))
        end 
      elsif query.present?
        @conditions[0] += " AND (tickets.asset_id in (?) OR tickets.employee_id in (?) OR tickets.id in (?))" 
        @conditions += [get_unscoped_asset_ids(query), get_unscoped_employee_ids(query), query]
      end
      add_conditions(" AND tickets.state = ?" , STATE[state.downcase.to_sym]) if state.present?
      add_conditions(" AND tickets.company_id = ?", current_employee.company_id)
    end

    def self.add_conditions(condition, value)
      @conditions[0] += condition
      @conditions << value
    end

    def self.get_unscoped_asset_ids(query)
      Asset.unscoped.where("assets.name like (?)", "%#{query}%").pluck(:id)      
    end

    def self.get_unscoped_employee_ids(query)
      Employee.unscoped.where("employees.name like (?)", "%#{query}%").pluck(:id)
    end

end