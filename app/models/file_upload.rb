class FileUpload < ActiveRecord::Base
  include Shared::RestrictiveDestroy

  has_attached_file :file

  belongs_to :asset
  belongs_to :uploader, class_name: "Employee", foreign_key: :employee_id

  validates :description, presence: true
  validates_length_of :description, :maximum=> 100

  validates :file, :attachment_presence => true
  validates_attachment_size :file, :less_than => 5.megabytes
  validates_attachment_content_type :file, :content_type => ['image/jpeg', 'image/png', 'image/gif', 'image/jpg', 'application/pdf', 'application/docx', 'application/doc']

  delegate :name, to: :uploader, prefix: :uploader

  def destroyable?
    !Asset.unscoped.where(id: asset_id).first.retired?
  end 

end