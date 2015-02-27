# Load the Rails application.
require File.expand_path('../application', __FILE__)
#Default path for paperclip to upload files
Paperclip::Attachment.default_options[:url] = "/uploads/:class/:attachment/:id/:style/:filename"
# Initialize the Rails application.
Rails4::Application.initialize!
