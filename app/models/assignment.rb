class Assignment < ActiveRecord::Base
  include AssignmentNotification
  include Commentable
  include AssetStatable

  self.table_name = "asset_employee_mappings"

  before_create :check_asset_status
  after_create :update_status
  after_update :update_aem_asset
  
  validates :asset_id, :date_issued, :employee_id, presence: true
  validates :date_returned, on: :update, presence: true
  validates :date_issued, :date => { :before => Proc.new { Time.current } }, allow_blank: true
  validates :date_returned, :on => :update, :date => { :before => Proc.new { Time.current } }, allow_blank: true
  validates :date_returned, :date => { :after => :date_issued, :message => 'must be after issued date' }, allow_blank: true
  validate :temporarly_assignment_date, :on => :create

  belongs_to :asset
  belongs_to :employee

  attr_accessor :assignment_type
  accepts_nested_attributes_for :comments, :allow_destroy => true

  alias_attribute :returned, :date_returned
  
  # Checks if the date_returned is not blank if assignment type is temporary
  def temporarly_assignment_date
    errors.add(:expected_return_date, " can't be blank for Temporary Assignment") if assignment_type == "false" && expected_return_date.blank?
  end

  def add_commenter(employee)
    comments.last.commenter_id = employee.id if comments.present?
  end

end