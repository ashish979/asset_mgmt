require 'set'
require 'audited/audit'

module Audited
  module Adapters
    module ActiveRecord
      class Audit < ::ActiveRecord::Base
        include Audited::Audit


        serialize :audited_changes

        default_scope         lambda { order(:version) }
        scope :descending,    lambda { reorder("version DESC") }
        scope :creates,       lambda { where(:action => 'create') }
        scope :updates,       lambda { where(:action => 'update') }
        scope :destroys,      lambda { where(:action => 'destroy') }

        scope :up_until,      lambda {|date_or_time| where("created_at <= ?", date_or_time) }
        scope :from_version,  lambda {|version| where(['version >= ?', version]) }
        scope :to_version,    lambda {|version| where(['version <= ?', version]) }

        # Return all audits older than the current one.
        def ancestors
          self.class.where(['auditable_id = ? and auditable_type = ? and version <= ?',
            auditable_id, auditable_type, version])
        end

        # Allows user to be set to either a string or an ActiveRecord object
        # @private
        def admin_as_string=(admin)
          # reset both either way
          self.admin_as_model = self.admin_id = nil
          admin.is_a?(::ActiveRecord::Base) ?
            self.admin_as_model = admin :
            self.admin_id = admin
        end
        alias_method :admin_as_model=, :admin=
        alias_method :admin=, :admin_as_string=

        # @private
        def admin_as_string
          self.admin_as_model || self.admin_id
        end
        alias_method :admin_as_model, :admin
        alias_method :admin, :admin_as_string

      private
        def set_version_number
          max = self.class.where(:auditable_id => auditable_id, :auditable_type => auditable_type).maximum(:version) || 0
          self.version = max + 1
        end
      end
    end
  end
end
