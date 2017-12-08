require File.expand_path(File.join(File.dirname(__FILE__), '../config', 'environment'))
Asset.update_all(:barcode => nil)

Asset.all.each{|asset| asset.update_attribute(:barcode, "#{asset.asset_type.id.to_s.rjust(4,'0')}#{asset.id.to_s.rjust(6,'0')}")}