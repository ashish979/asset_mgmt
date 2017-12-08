class TicketType < ActiveRecord::Base
  include Shared::RestrictiveDestroy
  
  has_many :tickets
  belongs_to :company

  validates :name, presence: true, uniqueness: { scope: :company_id, :case_sensitive => false }
  
  def new_hardware?
    name == "New Hardware"
  end

end