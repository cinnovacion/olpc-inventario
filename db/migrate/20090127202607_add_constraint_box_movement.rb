class AddConstraintBoxMovement < ActiveRecord::Migration
  extend DbUtil
  def self.up
	self.createConstraint("box_movements", "src_place_id", "places")
	self.createConstraint("box_movements", "src_person_id", "people")
	self.createConstraint("box_movements", "dst_place_id", "places")
	self.createConstraint("box_movements", "dst_person_id", "people")
	self.createConstraint("box_movements", "authorized_person_id", "people")
  end

  def self.down
	self.removeConstraint("box_movements", "src_place_id")
	self.removeConstraint("box_movements", "src_person_id")
	self.removeConstraint("box_movements", "dst_place_id")
	self.removeConstraint("box_movements", "dst_person_id")
	self.removeConstraint("box_movements", "authorized_person_id")
  end
end
