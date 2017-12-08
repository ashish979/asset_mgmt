class PropertiesController < ApplicationController
  before_filter :find_property_group, :only => :create
  before_filter :find_property, :only => :destroy
  authorize_resource
  
  def create
    @property = @property_group.properties.build params_property
    @property.company_id = current_company.id
    if @property.save 
      redirect_to property_group_path(@property_group), :notice => "Property #{@property.name} has been created successfully"
    else
      @properties = @property_group.properties.paginate(page: params[:page], per_page: 100)
      render :template => 'property_groups/show'
    end
  end

  def destroy
    @property_group = @property.property_group
    if @property.destroy
      redirect_to property_group_path(@property_group), :notice => "Property #{@property.name} has been deleted successfully"
    else
      redirect_to property_group_path(@property_group), :alert => "Property could not be deleted"
    end
  end

  private

    def find_property_group
      @property_group = current_company.property_groups.where(id: params[:property][:property_group_id]).first
      redirect_to property_groups_path, :alert => "Property group not found" unless @property_group
    end

    def find_property
      @property = current_company.properties.where(id: params[:id]).includes(:property_group).first
      redirect_to :back, :alert => "Property not found for specified id" unless @property
    end

    def params_property
      params.require(:property).permit(:name)
    end

end
