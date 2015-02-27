class Employee
  module Devisable
    extend ActiveSupport::Concern
    
    def attempt_set_password(params)
      p = {}
      p[:password] = params[:password]
      p[:password_confirmation] = params[:password_confirmation]
      update_attributes(p)
    end
    
    # new function to return whether a password has been set
    def has_no_password?
      encrypted_password.blank?
    end

    # new function to provide access to protected method unless_confirmed
    def only_if_unconfirmed
      pending_any_confirmation {yield}
    end
    
    def password_required?
      # Password is required if it is being set, but not for new records
      if !self.persisted? 
        false
      else
        !password.nil? || !password_confirmation.nil?
      end
    end
    
    def active_for_authentication?
      eligible = has_role?(:super_admin) ? true : company.enabled?
      has_any_role? && eligible && super 
    end

    def inactive_message
      if has_any_role?
        company.enabled? ? super : :deactivated 
      else
        "Your account has been disabled"
      end
    end
  end
end