require File.expand_path(File.join(File.dirname(__FILE__), '../config', 'environment'))

Company.create(name: "Vinsol", email: "hr@vinsol.com", website: "http://www.vinsol.com")
comp_id = Company.first

Employee.update_all(company_id: comp_id)
Asset.update_all(company_id: comp_id)
Tag.update_all(company_id: comp_id)