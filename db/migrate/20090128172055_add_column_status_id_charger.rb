class AddColumnStatusIdCharger < ActiveRecord::Migration
  extend DbUtil
  def self.up
	add_column(:chargers,:status_id,:integer)
	self.createConstraint("chargers", "status_id", "statuses")
  end

  def self.down
	self.removeConstraint("chargers", "status_id")
	remove_column(:chargers,:status_id)
  end
end
