class AssetsController < ApplicationController
  autocomplete :tag, :name, :full => true, :limit => 1000
  autocomplete :asset, :brand, :full => true, :limit => 1000
  autocomplete :asset, :vendor, :full => true, :limit => 1000

  before_action :find_asset, :only => [:edit, :update, :retire_asset, :remove_tag]
  before_action :find_unscoped_asset, :only => [:uploaded_files, :tickets, :show]

  authorize_resource 
  
  def index
    if params[:asset_type_id].present?
      @assets = current_company.assets.where(asset_type_id: params[:asset_type_id])
    elsif params[:type] == 'retired'
      @assets = Asset.retired_assets(current_company)
      @assets = @assets.order('id asc') unless params[:sort]
    else
      @assets = current_company.assets
    end
    @assets = @assets.order(params[:sort]) if params[:sort]
    @assets = @assets.includes(:asset_type, :assignments, :active_assignments => :employee).paginate(page: params[:page], per_page: 100)
  end
  
  def show
    @comments = @asset.comments.includes(:commenter).order("created_at desc")
    @comment = @asset.comments.build 
    @asset_properties = @asset.asset_properties.includes(:property)
    if request.xhr? && params[:query] == 'history'
      @audits = @asset.audits.includes(:admin).order('audits.created_at desc')
      @property_audits = Audited::Adapters::ActiveRecord::Audit.where(auditable_type: "AssetProperty", auditable_id: @asset.asset_properties.collect(&:id)).includes(:associated).order('audits.created_at desc')
    end
  end

  def new
    find_asset_type if params[:asset_type_id]
    @asset = Asset.new
    @file_uploads = @asset.file_uploads.build
  end
  
  def create
    @asset = current_company.assets.build params_asset
    if @asset.save
      redirect_to [@asset.asset_type, @asset], :notice => "#{@asset.name} has been created successfully"
    else
      find_asset_type if params[:asset_type_id]
      @file_uploads = @asset.file_uploads.build if @asset.file_uploads.blank?
      render :action => "new"
    end     
  end
    
  def edit
    @asset_type = @asset.asset_type
    @file_uploads = @asset.file_uploads.build
  end

  def update
    if @asset.update_attributes(params_asset)
      @asset.file_uploads.build
      respond_to do |format|
        format.js {flash.now[:notice] = "File uploaded successfully"}
        format.html { redirect_to [@asset.asset_type, @asset], :notice => "#{@asset.name} has been updated successfully" }
      end
    else
      unless request.xhr?
        @asset_type = @asset.asset_type
        @file_uploads = @asset.file_uploads.build if @asset.file_uploads.blank?
        render :action => "edit"
      end
    end
  end

  def retire_asset
    return redirect_to :back, :alert => "Asset is assigned, first return then retire it" unless @asset.can_retire?

    if @asset.update_attribute(:deleted_at, Time.now)
      redirect_to [@asset.asset_type, @asset], :notice => "#{@asset.name} has been retired successfully"
    else
      redirect_to [@asset.asset_type, @asset], :alert => "There is some problem, Please contact support"
    end
  end
  
  def get_autocomplete_items(parameters)
    result = super(parameters).where(:company_id => current_company.id)
    if parameters[:method] == :vendor
      result = result.group('assets.vendor') 
    elsif parameters[:method] == :brand 
      result = result.group('assets.brand') 
    end
    result
  end

  def remove_tag
    @tag = Tag.where(id: params[:tag_id]).first
    if @tag && @asset.remove_tags(@tag.id) 
      flash.now[:notice] = "Tag #{@tag.name} has been removed successfully"
    else
      flash.now[:alert] = "Tag could not be removed"
    end
  end

  def uploaded_files
    @file_uploads = @asset.file_uploads.build
  end

  def tickets
    @tickets = @asset.tickets.includes(:ticket_type, :employee, :asset).order("tickets.created_at desc").paginate(page: params[:page], per_page: 100)
  end

  def autocomplete_assets_name
    names = Asset.select([:name, :serial_number]).where("(name LIKE ? OR serial_number like ?) AND company_id = ?", "%#{params[:query]}%", "%#{params[:query]}%", current_company.id)
    result = names.collect do |t|
      { value: t.name,
       serial_number: t.serial_number
     }
    end
    render json: result
  end

  private
  
    def find_asset
      @asset = current_company.assets.where(id: params[:id]).first
      redirect_to root_path, :alert => "Record not found" unless @asset
    end

    def find_unscoped_asset
      @asset = Asset.unscoped.where(company_id: current_company.id, id: params[:id]).first
      redirect_to root_path, :alert => "Record not found" unless @asset
    end

    def find_asset_type
      @asset_type = current_company.asset_types.where(id: params[:asset_type_id]).first
    end

    def params_asset
      params.require(:asset).permit(:name, :status, :cost, :serial_number, :purchase_date, :brand, :vendor, :asset_type_id, :tags_field, :description, :additional_info, :currency_unit, :company_id, :file_uploads_attributes => [:file, :description, :id, :_destroy, :employee_id])
    end

end
