class CreateParts < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :parts do |t|
      t.integer :status_id
      t.integer :owner_id
      t.integer :part_type_id
      t.integer :laptop_id
      t.integer :battery_id
      t.integer :charger_id
    end

  self.createConstraint("parts", "status_id", "statuses")
  self.createConstraint("parts", "owner_id", "people")
  self.createConstraint("parts", "part_type_id", "part_types")
  self.createConstraint("parts", "laptop_id", "laptops")
  self.createConstraint("parts", "battery_id", "batteries")
  self.createConstraint("parts", "charger_id", "chargers")

  end

  def self.down
    drop_table :parts
  end
end
