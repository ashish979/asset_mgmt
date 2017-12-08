class CommentsController < ApplicationController
  load_resource only: :destroy
  before_action :find_resource, only: :create
  authorize_resource 
  
  def create
    if request.xhr?
      @comment = @resource.comments.build params_comments
      @comment.commenter_id = current_employee.id if current_employee
      if @comment.save
        @comments = @resource.comments.includes(:commenter)
        @comments = @comments.order("created_at desc") if resource_class != Ticket
        flash.now[:notice] = "Comment Added Successfully"
      end
    else
      redirect_to root_url, :alert => "Invalid request"   
    end
  end

  def destroy
    if request.xhr?
      @resource = resource_class.unscoped.where(id: @comment.resource_id, company_id: current_company.id).first
      return_requester unless @resource
      if @comment.destroy
        @comments = @resource.comments.includes(:commenter).order("created_at desc")
        flash.now[:notice] = "Comment Deleted Successfully"
      else
        flash.now[:alert] = "Comment could not be deleted"
      end
    else
      redirect_to root_url, :alert => "Invalid request"     
    end
  end

  private

    def params_comments
      params.require(:comment).permit(:body, :resource_id)
    end

    def find_resource
      @resource = resource_class.unscoped.where(id: params[:comment][:resource_id], company_id: current_company.id).first
      return_requester unless @resource
      if !current_employee.has_role?(:admin) && resource_class != "Ticket" && @resource.employee_id != current_employee.id
        return_requester  
      end
    end

    def resource_class
      params[:resource_class].classify.constantize
    end

    def return_requester
      flash.now[:alert] = "Record not found"
      return render :partial => 'shared/missing_record' 
    end
end