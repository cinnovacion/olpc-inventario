class AddConstraintBox < ActiveRecord::Migration
  extend DbUtil
  def self.up
	self.createConstraint("boxes", "shipment_id", "shipments")
	self.createConstraint("boxes", "place_id", "places")
  end

  def self.down
	self.removeConstraint("boxes", "shipment_id")
	self.removeConstraint("boxes", "place_id")
  end
end
