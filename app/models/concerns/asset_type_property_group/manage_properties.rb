class AssetTypePropertyGroup
  module ManageProperties
    extend ActiveSupport::Concern

    included do
      after_create :update_asset_properties
      before_destroy :destroy_asset_properties
    end

    protected

      def update_asset_properties
        asset_type.assets.each do |asset|
          asset.properties << self.property_group.properties 
        end
      end

      def destroy_asset_properties
        asset_type.assets.includes(:asset_properties).each do |asset|
          asset.asset_properties.where("asset_properties.property_group_id = ?", self.property_group_id).destroy_all
        end
      end

  end
end