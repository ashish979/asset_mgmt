Audited::Adapters::ActiveRecord::Audit.all.each do |audit|
  if !audit.audited_changes[audit.audited_changes.keys.first].is_a?(Array)
    audit.delete 
  elsif audit.audited_changes[audit.audited_changes.keys.first][0].blank?
    audit.delete unless audit.audited_changes.keys.first == 'deleted_at'
  end
end