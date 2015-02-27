class EmployeesController < ApplicationController
  autocomplete :employee, :name, :full => true, :limit => 1000

  before_filter :find_employee, :only => [:edit, :update, :disable]
  before_filter :find_unscoped_employee, :only => :show
  authorize_resource
  skip_authorize_resource only: [:edit_password, :update_password]
  
  def index
    if params[:type].blank?
      @employees = Employee.with_deleted{ Employee.where(company_id: current_company.try(:id)) }
    else
      @employees = Employee.send(params[:type], current_company)
    end
    @employees = @employees.includes(:assignments, :roles).order('name asc').paginate :page => params[:page], :per_page => 100
  end

  def show
    @history = @employee.returned_assignments.includes(asset: :asset_type).order('asset_employee_mappings.date_returned desc')
  end

  def new
    @employee = Employee.new
  end

  def create
    @employee = current_company.employees.new params_employee
    if @employee.save
      redirect_to employees_path, :notice => "Employee #{@employee.name} has been created successfully"
    else
      render :action => "new" 
    end   
  end

  def edit
  end

  def update
    unless request.xhr?
      if @employee.update_attributes(params_employee)
        redirect_to(@employee, :notice => "Employee #{@employee.name} has been updated successfully")
      else
        render :action => "edit"
      end
    else
      return flash.now[:notice] = "You can not disable yourself" if @employee == current_employee
      @employee.manage_admin_role!
      flash.now[:notice] = "#{@employee.name} #{@employee.has_role?(:admin) ? 'marked as admin' : 'is no longer admin'}"
    end
  end
    
  def enable
    employee = current_company.employees.with_deleted{ current_company.employees.where(:id => params[:id]).first }
    if employee.soft_undelete!
      redirect_to :back, :notice => "Employee #{employee.name} has been enabled successfully"
    else
      redirect_to :back, :alert => "Employee #{employee.name} has not been enabled successfully"
    end 
  end
  
  ## Used to soft delete the employees, will not let them delete if any asset is assigned to them
  def disable
    unless @employee.can_be_disabled?
      redirect_to :back, :alert => "First remove all assigned asset from #{@employee.name}"
    else
      @employee.soft_delete!  
      redirect_to :back, :notice => "Employee #{@employee.name} has been disabled successfully"
    end
  end

  def get_autocomplete_items(parameters)
    super(parameters).where(:company_id => current_company.id)
  end
  
  #to reset the password
  def edit_password
    @employee = current_employee
  end

  #to update the password
  def update_password
    @employee = current_employee
    if @employee.update_with_password(params_employee)
      redirect_to root_path
    else
      render :action => "edit_password"
    end
  end

  def assignment_report
    @employees = Employee.enabled(current_company).includes(active_assignments: :asset).order('name asc')
    @employees = @employees.paginate :page => params[:page], :per_page => 100 unless request.xhr?
    @employees
  end

  protected
  
  def find_employee
    @employee = current_company.employees.where(:id => params[:id]).first
    redirect_to root_path, :alert => "Could not find employee" unless @employee
  end

  def find_unscoped_employee
    @employee = Employee.unscoped.where(id: params[:id], company_id: current_company.try(:id)).includes(active_assignments: {asset: :asset_type}).first
    redirect_to root_path, :alert => "Employee not found for specified id" unless @employee
  end
  
  def params_employee
    params.require(:employee).permit(:name, :employee_id, :email, :current_password, :password, :password_confirmation)
  end 
  
end
