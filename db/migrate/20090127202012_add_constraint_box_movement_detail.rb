class AddConstraintBoxMovementDetail < ActiveRecord::Migration
  extend DbUtil
  def self.up
	self.createConstraint("box_movement_details", "box_movement_id", "box_movements")
	self.createConstraint("box_movement_details", "box_id", "boxes")
  end

  def self.down
	self.removeConstraint("box_movement_details", "box_movement_id")
	self.removeConstraint("box_movement_details", "box_id")
  end
end
