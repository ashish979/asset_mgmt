class CompaniesController < ApplicationController
  skip_before_filter :verify_current_company
  
  before_action :find_company, :only => [:edit, :update, :change_status]
  authorize_resource  
  
  def index
    @companies = Company.all.paginate(page: params[:page], per_page: 100)
  end

  def new
    @company = Company.new
  end

  def edit
  end

  def create 
    @company = Company.new params_company
    if @company.save
      redirect_to companies_path, :notice => "Company #{@company.name} has been created successfully"
    else
      render 'new'
    end
  end

  def update
    if @company.update_attributes(params_company)
      redirect_to companies_path, :notice => "Company #{@company.name} has been updated successfully"
    else
      render :action => "edit"
    end
  end

  def change_status
    @company.toggle!(:status)
    redirect_to companies_path, :notice => "Company #{@company.name} has been #{@company.enabled? ? 'enabled' : 'disabled'} successfully"
  end

  private

    def find_company
      @company = Company.where(permalink: params[:id]).first
      redirect_to companies_path, :alert => "Company not found for specified id" unless @company
    end

    def params_company
      params.require(:company).permit(:name, :email, :website)
    end
end