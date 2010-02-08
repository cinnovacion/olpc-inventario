class CreateLaptopDetails < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :laptop_details do |t|
      t.integer :section_detail_id
      t.integer :person_id
      t.integer :laptop_id
    end
    self.createConstraint("laptop_details", "section_detail_id", "section_details")
    self.createConstraint("laptop_details", "person_id", "people")
    self.createConstraint("laptop_details", "laptop_id", "laptops")
  end

  def self.down
    self.removeConstraint("laptop_details", "section_detail_id")
    self.removeConstraint("laptop_details", "person_id")
    self.removeConstraint("laptop_details", "laptop_id")
    drop_table :laptop_details
  end
end
