require File.expand_path(File.join(File.dirname(__FILE__), '../config', 'environment'))

assignments = Assignment.all.includes(:comments)

assignments.each do |assignment|
  if assignment.comments.present? 
    if assignment.comments.first.created_at == assignment.created_at
      #No need to create or update it.
    else
      remark = assignment.comments.first.try(:body)
      assignment.comments.delete_all
      assignment.comments.create(body: nil)
      assignment.comments.create(body: remark)
    end
  else
    assignment.comments.create(body: nil)
  end
end