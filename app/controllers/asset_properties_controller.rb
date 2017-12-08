class AssetPropertiesController < ApplicationController
  autocomplete :property, :name, :full => true, :limit => 1000
  before_action :find_asset_property, :only => [:destroy, :update]
  before_action :find_asset, :only => :index
  authorize_resource

  def index
    @asset = current_company.assets.where(id: params[:id]).includes(:asset_properties).first
    @asset_property_groups = @asset.property_groups.includes(:properties)
  end

  def edit
    @asset_property = current_company.asset_properties.where(id: params[:id]).first
  end

  def update
    if @asset_property.update_attributes(params_asset_property)
      message = {:notice => "Property #{@asset_property.property.try(:name)} has been updated successfully"}
    else
      message = {:alert => "Value of property #{@asset_property.property.try(:name)} not updated"}
    end
    respond_to do |format|
      format.html { redirect_to edit_asset_type_asset_path(@asset_property, @asset_property.asset), message }
      format.js { flash.now[message.keys.first] = message.values.first }
    end
  end

  def destroy
    @asset = @asset_property.asset 
    if @asset_property.destroy
      @asset_property_groups = @asset.property_groups.includes(:properties)
      respond_to do |format|
        format.html { redirect_to asset_properties_index_path(@asset), :notice => "Property #{@asset_property.property.try(:name)} has been removed successfully" }
        format.js  { flash.now[:notice] = "Property #{@asset_property.property.try(:name)} has been removed successfully" }
      end
    end
  end

  private

    def find_asset_property
      @asset_property = AssetProperty.where(id: params[:id]).first
      unless @asset_property
        flash.now[:alert] = "There is no asset type with id: #{params[:id]}"
        return render :partial => 'find_asset_property' 
      end
    end

    def params_asset_property
      params.require(:asset_property).permit(:value, :property_id, :company_id)
    end

    def find_asset
      @asset = current_company.assets.where(id: params[:id]).includes(:asset_properties).first
      redirect_to root_path, :alert => "Record not found" unless @asset   
    end

end
