class Asset     
  module ManagePropertyGroups
    extend ActiveSupport::Concern

    included do
      before_create :assign_property_groups
    end
     
    def assign_property_groups
      if asset_type.present?
        asset_type.property_groups.each do |property_group|
          self.properties << property_group.properties if  property_group.properties.present?
        end
      end 
    end

  end
end