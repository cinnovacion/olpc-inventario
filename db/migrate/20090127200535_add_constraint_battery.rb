class AddConstraintBattery < ActiveRecord::Migration
  extend DbUtil
  def self.up
	self.createConstraint("batteries", "owner_id", "people")
	self.createConstraint("batteries", "shipment_arrival_id", "shipments")
	self.createConstraint("batteries", "box_id", "boxes")	
  end

  def self.down
	self.removeConstraint("batteries", "owner_id")
	self.removeConstraint("batteries", "shipment_arrival_id")
	self.removeConstraint("batteries", "box_id")
  end
end
