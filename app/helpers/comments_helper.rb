module CommentsHelper
  def show_commenter_name(comment)
    unless (emp = comment.commenter).present?
      emp = Employee.unscoped.where(id: comment.commenter_id).first
    end
    
    return "-" unless emp.present?

    if can? :read, Employee     
      "#{link_to emp.name, emp}".html_safe
    else
      "#{emp.name}".html_safe
    end
  end
end