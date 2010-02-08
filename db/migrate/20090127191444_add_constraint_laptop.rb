class AddConstraintLaptop < ActiveRecord::Migration
  extend DbUtil
def self.up
	self.createConstraint("laptops", "model_id", "models")
	self.createConstraint("laptops","box_id","boxes")
  end

  def self.down
	self.removeConstraint("laptops","model_id")
	self.removeConstraint("laptops","box_id")
  end
end
