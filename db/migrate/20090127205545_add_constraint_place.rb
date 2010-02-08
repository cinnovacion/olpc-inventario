class AddConstraintPlace < ActiveRecord::Migration
  extend DbUtil
  def self.up
	self.createConstraint("places", "place_id", "places")
  end

  def self.down
	self.removeConstraint("places", "place_id")
  end
end
