class AddColumnStatusIdLaptop < ActiveRecord::Migration
  extend DbUtil
  def self.up
	add_column(:laptops,:status_id,:integer)
	self.createConstraint("laptops", "status_id", "statuses")
  end

  def self.down
	self.removeConstraint("laptops", "status_id")
	remove_column(:laptops,:status_id)
  end
end
