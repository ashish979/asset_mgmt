class HistoriesController < ApplicationController
  
  def index
    if params[:type] == "employee"
      @record = Employee.with_deleted{ Employee.where(:id => params[:id], company_id: current_company.try(:id)).first }
    else
      @record = Asset.unscoped.where(:id => params[:id], company_id: current_company.try(:id)).first
    end 
    return redirect_to :back, :alert => "There are no history" unless @record
    @histories = @record.assignments.includes(params[:type] == 'employee' ? :asset : :employee, :comments).order('asset_employee_mappings.date_returned desc')
  end
end