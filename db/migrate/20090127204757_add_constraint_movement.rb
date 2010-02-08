class AddConstraintMovement < ActiveRecord::Migration
  extend DbUtil
  def self.up
	self.createConstraint("movements", "responsible_person_id", "people")
	self.createConstraint("movements", "source_person_id", "people")
	self.createConstraint("movements", "destination_person_id", "people")
	self.createConstraint("movements", "movement_type_id", "movement_types")
  end

  def self.down
	self.removeConstraint("movements", "responsible_person_id")
	self.removeConstraint("movements", "source_person_id")
	self.removeConstraint("movements", "destination_person_id")
	self.removeConstraint("movements", "movement_type_id")
  end
end
