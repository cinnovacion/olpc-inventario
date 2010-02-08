class AddConstraintActivation < ActiveRecord::Migration
  extend DbUtil
  def self.up
	self.createConstraint("activations", "laptop_id", "laptops")
	self.createConstraint("activations", "person_activated_id", "people")
  end

  def self.down
	self.removeConstraint("activations", "laptop_id")
	self.removeConstraint("activations", "person_activated_id")
  end
end
