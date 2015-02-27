class Comment < ActiveRecord::Base
  include CommentNotification
  include Shared::RestrictiveDestroy
  
  belongs_to :resource, :polymorphic => true
  belongs_to :commenter, :class_name => 'Employee', :foreign_key => 'commenter_id'

  validates :body, presence: true, :if => "resource_type && resource_type != 'Assignment'"
  
  def destroyable?
    return false if resource_type == "Ticket"
  end  
  
end