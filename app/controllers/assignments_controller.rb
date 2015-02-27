class AssignmentsController < ApplicationController

  before_action :find_assinable_assets, only: :populate_asset
  before_action :find_assignment, only: :update
  authorize_resource

  def new
    if params[:asset_type_id]
      @asset_type = AssetType.where(id: params[:asset_type_id]).first
      @asset = Asset.where(id: params[:asset_id]).first
    end
    @assignment = Assignment.new
    @assignment.comments.build
  end
  
  def create
    @assignment = Assignment.new assignment_params
    @assignment.add_commenter(current_employee)
    if @assignment.save
      redirect_to @assignment.employee, :notice => "#{@assignment.asset.name} has been successfully assigned to #{@assignment.employee.try(:name)}"
    else
      @assignment.comments.build if @assignment.comments.blank?
      render :action => 'new'
    end
  end
  

  def return_asset
    @assignment = Assignment.where(:asset_id => params[:id]).assigned_assets.includes(:asset, :comments).first
    return redirect_to assets_path, :alert => "No asset is assigned to selected pair" if @assignment.blank?
    @assignment.comments.build 
  end

  def update
    @assignment.attributes = assignment_params
    @assignment.add_commenter(current_employee)
    if @assignment.save
      redirect_to employee_path(@assignment.employee), :notice => "#{@assignment.asset.try(:name)} has been returned successfully"
    else
      @assignment.comments.build if @assignment.comments.blank?
      render :action => 'return_asset'
    end
  end
  
  
  # Will change the return form according to the selected asset to be returned - Using AJAX
  def change_aem_form
    if params[:barcode]
      find_assinable_assets
      @asset = @assets.where(barcode: params[:barcode]).first
      return flash.now[:alert] = "There is no spare asset with barcode: #{params[:barcode]}" unless @asset
      @assets = @assets.where(asset_type_id: @asset.asset_type_id)
    else
      @asset_type = current_company.assets.where(id: params[:asset]).first.try(:asset_type_id)
    end
  end
  
  # Will populate the select box according to the category of asset and when the status is not assigned - Using AJAX
  def populate_asset
    @assets = @assets.where(asset_type_id: params[:category]) if params[:category].present?
  end
  
  private 

    def assignment_params
      params.require(:assignment).permit(:asset_id, :employee_id, :date_issued, :date_returned, :expected_return_date, :assignment_type, comments_attributes:[:body,  :commenter_id])
    end

    def find_assinable_assets
      @assets = current_company.assets.assignable
    end

    def find_assignment
      @assignment = Assignment.where(:id => params[:id]).first
      redirect_to :back, :alert => "Assignment not found for specified id" unless @assignment
    end
end
