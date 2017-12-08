module Shared::RestrictiveDestroy
  extend ActiveSupport::Concern

  included do
    before_destroy :destroyable?
  end
  
  protected

    def destroyable?
      return false
    end

end
