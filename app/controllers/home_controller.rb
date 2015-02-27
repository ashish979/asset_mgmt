class HomeController < ApplicationController
  before_action :assign_variables, :only => :search

  def index
    return redirect_to companies_path if current_employee.has_role?(:super_admin)
    if current_employee.has_role?(:admin)
      @tags = current_company.tags.includes(:assets).paginate :page => params[:page], :per_page => 100
    else
      @assignments = current_employee.active_assignments.includes(:asset)
    end
  end
  
  #will search assets and employees and will filter it according to status, category, asset type, to , from, employee
  def search
    authorize! :read, current_employee
    return find_asset_from_barcode if params[:barcode].present?
    if params[:tag].present?
      find_assets_from_tag
    else
      if has_asset_attributes?
        @result = current_company.assets.search(@asset, @status, @category, @from, @to, @opt_employee)
      else
        find_employees
      end
    end
    @result = @result.paginate :page => params[:page], :per_page => 100 if @result.present? && !params[:print]
    @result
  end
  
  #will show assets in  the tags in the home page - Using AJAX
  def show_tag
    authorize! :read, current_employee
    @tag = Tag.where(:id => params[:tag_id]).first
    @assets = @tag.assets.paginate :page => params[:page], :order => 'created_at asc', :per_page => 100
  end

  private
    def find_asset_from_barcode
      @asset = Asset.where(barcode: params[:barcode]).first
      redirect_to [@asset.asset_type, @asset] if @asset
      flash.now[:alert] = "No Asset found with barcode: #{params[:barcode]}"
    end

    def find_assets_from_tag
      tag = current_company.tags.where(name: params[:tag]).first
      @result = tag.assets if tag
    end

    def find_employees
      if is_numeric?(params[:employee])
        @result = current_company.employees.where("employees.employee_id = ?", @opt_employee) 
      else
        @result = current_company.employees.where("employees.name like ?", "%#{@opt_employee}%")
      end
    end

    def has_asset_attributes?
      @asset.present? || @category.present? || @status.present? || @to.present? || @from.present?
    end

    def assign_variables
      params[:employee] = params[:employee].to_i if params[:employee] && is_numeric?(params[:employee])
      @asset, @opt_employee, @status, @category, @to, @from = params[:asset],  params[:employee], params[:status], params[:category], params[:to], params[:from]  
    end

    def is_numeric?(obj) 
      obj.to_s.match(IS_NUMERIC) ? true : false
    end
    
end
