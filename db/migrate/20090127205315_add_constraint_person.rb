class AddConstraintPerson < ActiveRecord::Migration
  extend DbUtil
  def self.up
	self.createConstraint("people", "place_id", "places")
  end

  def self.down
	self.removeConstraint("people", "place_id")	
  end
end
