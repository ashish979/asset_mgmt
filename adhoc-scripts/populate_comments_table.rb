require File.expand_path(File.join(File.dirname(__FILE__), '../config', 'environment'))

@history_comments = HistoryComment.all
@history_comments.each do |hc|
  Comment.create(resource_id: hc.asset_id, resource_type: 'Asset', body: hc.comment, commenter_id: hc.commenter_id) 
end