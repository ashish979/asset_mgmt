Company.all.each do |c|
  c.generate_permalink!
  c.save!
end