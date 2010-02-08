class RemoveTypeMovementDetail < ActiveRecord::Migration
  extend DbUtil
  def self.up
    self.removeConstraint("movement_details", "movement_type_id")
    remove_column :movement_details,:movement_type_id
  end

  def self.down
    add_column :movement_details,:movement_type_id,:integer
    self.createConstraint("movement_details", "movement_type_id","movement_types")
  end
end
