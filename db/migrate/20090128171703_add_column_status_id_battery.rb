class AddColumnStatusIdBattery < ActiveRecord::Migration
  extend DbUtil
  def self.up
	add_column(:batteries,:status_id,:integer)
	self.createConstraint("batteries", "status_id", "statuses")
  end

  def self.down
	self.removeConstraint("batteries", "status_id")
	remove_column(:batteries,:status_id)
  end
end
