class AddConstraintOwnerLaptop < ActiveRecord::Migration
  extend DbUtil
  def self.up
    self.createConstraint("laptops", "owner_id", "people")
  end

  def self.down
    self.removeConstraint("laptops", "owner_id")
  end
end
