class Asset     
  module StatusMachine
    extend ActiveSupport::Concern

    included do
      STATUS = {"Operational" => 'operational', "Recieved" => 'recieved', "Spare" => 'spare', "Repair" => 'repair', "Assigned" => 'Assigned' }
      scope :assignable, -> { where.not(status: [STATUS["Assigned"], STATUS["Repair"]]) }     
    end
    
    def can_retire?
      status != STATUS["Assigned"]
    end
    
    def assignable?
      ![STATUS["Assigned"], STATUS["Repair"]].include?(status) && !retired?
    end

    def mark_spare!
      update_attributes(:status => STATUS["Spare"])
    end

    def assign! 
      update_attributes(:status => STATUS["Assigned"])
    end
  end
end