class AssetTypesController < ApplicationController
  before_action :find_asset_type, :only => [:show, :update, :destroy]
  authorize_resource

  def index
    #to create a asset type only name is required so we are showing form on index page which needs it to be intialized here.
    @asset_type = current_company.asset_types.build
    build_asset_type_property_groups
    find_assets
  end

  def create
    @asset_type = current_company.asset_types.build params_asset_type
    if @asset_type.save
      redirect_to asset_types_path, :notice => "Asset type #{@asset_type.name} has been created successfully"
    else
      find_assets
      build_asset_type_property_groups
      render 'index'
    end
  end

  def update
    if @asset_type.update_attributes(params_asset_type)
      flash[:notice] = "Asset type #{@asset_type.name} has been updated successfully"
      redirect_to asset_types_path
    else
      find_assets
      build_asset_type_property_groups
      render :index
    end
  end

  def show
    return redirect_to request.referrer if !request.xhr?
    build_asset_type_property_groups
  end

  def destroy
    if @asset_type.destroy
      redirect_to asset_types_path, :notice => "Asset type #{@asset_type.name} has been deleted successfully"
    else
      redirect_to asset_types_path, :alert => "There is some problem,please contact support"
    end
  end

  private
    def find_asset_type
      @asset_type = current_company.asset_types.includes(:property_groups, :asset_type_property_groups).where(id: params[:id]).first
      unless @asset_type
        redirect_to request.referrer, :alert => "There is no asset type found for specified id"
      end
    end

    def build_asset_type_property_groups
      if (@asset_type_property_groups = @asset_type.asset_type_property_groups + current_company.property_groups.where(["id NOT IN (?)", @asset_type.asset_type_property_groups.collect(&:property_group_id)]).collect { |pg| pg.asset_type_property_groups.build }).blank?
        @asset_type_property_groups = current_company.property_groups.collect { |pg| pg.asset_type_property_groups.build }
      end
    end

    def find_assets
      @asset_types = current_company.asset_types.includes(:property_groups, :assets).paginate(page: params[:page], per_page: 100)
    end

    def params_asset_type
      params.require(:asset_type).permit(:name, :asset_type_property_groups_attributes => [:id, :property_group_id, :_destroy])
    end
end