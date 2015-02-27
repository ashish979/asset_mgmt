class AssetType
  module RestrictiveDestroy
    extend ActiveSupport::Concern

    included do
      before_destroy :destroyable?
    end
    
    def destroyable?
      Asset.unscoped.where(asset_type_id: self.id).blank?
    end

  end
end