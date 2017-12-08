class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
 	 		t.string :name
	    t.string :email
	    t.text :website

      t.timestamps
    end
  end
end
