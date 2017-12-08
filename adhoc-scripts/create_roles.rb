require File.expand_path(File.join(File.dirname(__FILE__), '../config', 'environment'))

roles = %w[super_admin admin employee]

roles.each do|r|
  Role.create(name: r)
end