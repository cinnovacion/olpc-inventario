class AddConstraintCharger < ActiveRecord::Migration
  extend DbUtil
  def self.up
	self.createConstraint("chargers", "owner_id", "people")
	self.createConstraint("chargers", "shipment_arrival_id", "shipments")
	self.createConstraint("chargers", "box_id", "boxes")
  end

  def self.down
	self.removeConstraint("chargers", "owner_id")
	self.removeConstraint("chargers", "shipment_arrival_id")
	self.removeConstraint("chargers", "box_id")
  end
end
