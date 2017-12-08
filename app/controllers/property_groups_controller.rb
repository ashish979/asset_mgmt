class PropertyGroupsController < ApplicationController
  before_action :find_property_group, :only => [:show, :destroy]
  authorize_resource
  
  def index
    #we are using from on index page because it required only to fill name of group, that's why we are intializing it here,
    @property_group = current_company.property_groups.build
    find_property_groups
  end

  def create
    @property_group = current_company.property_groups.build params_group_property
    if @property_group.save
      redirect_to property_groups_path, :notice => "Property group #{@property_group.name} has been created successfully"
    else
      #if we redirect then error related to @property_group will be lost, rendering required see comment in index action. 
      find_property_groups
      render 'index'
    end
  end

  def show
    @property = @property_group.properties.build
    @properties = @property_group.properties.paginate(page: params[:page], per_page: 100)
  end

  def destroy
    if @property_group.destroy
      redirect_to property_groups_path, :notice => "Property group #{@property_group.name} has been deleted successfully"
    else
      redirect_to property_groups_path, :alert => "Property group #{@property_group.name} has not been deleted,please contact support"
    end
  end

  private
    def find_property_group
      @property_group = current_company.property_groups.where(id: params[:id]).first
      redirect_to :back, :alert => "Property group not found for specified id" unless @property_group
    end

    def find_property_groups
      @property_groups = current_company.property_groups.includes(:properties).paginate(page: params[:page], per_page: 100) 
    end

    def params_group_property
      params.require(:property_group).permit(:name)
    end
end