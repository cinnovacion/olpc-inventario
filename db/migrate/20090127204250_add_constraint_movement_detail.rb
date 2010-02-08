class AddConstraintMovementDetail < ActiveRecord::Migration
  extend DbUtil
  def self.up
	self.createConstraint("movement_details", "movement_id", "movements")
	self.createConstraint("movement_details", "laptop_id", "laptops")
	self.createConstraint("movement_details", "battery_id", "batteries")
	self.createConstraint("movement_details", "charger_id", "chargers")
	self.createConstraint("movement_details", "movement_type_id", "movement_types")
  end

  def self.down
	self.removeConstraint("movement_details", "movement_id")
	self.removeConstraint("movement_details", "laptop_id")
	self.removeConstraint("movement_details", "battery_id")
	self.removeConstraint("movement_details", "charger_id")
	self.removeConstraint("movement_details", "movement_type_id")
  end
end