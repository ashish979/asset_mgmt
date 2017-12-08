class Assignment
  module AssetStatable
    extend ActiveSupport::Concern
    
    included do 
      #Scope which will return assets which are assigned after checking Asset & AEM status
      scope :assigned_assets, lambda { joins(:asset).where(assets: {status: Asset::STATUS["Assigned"]}, date_returned: nil) }
    end

    #Used to update status of AEM and assets when a new asset is assigned
    def update_status
      asset.assign!
    end
    
    #to check in before create, asset is already assigned to someone?, it can be assign or not
    def check_asset_status
      asset.assignable?
    end
    
    def update_aem_asset
      asset.mark_spare!
    end

  end
end