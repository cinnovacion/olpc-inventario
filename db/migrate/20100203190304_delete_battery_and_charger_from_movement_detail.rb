class DeleteBatteryAndChargerFromMovementDetail < ActiveRecord::Migration
  extend DbUtil
  def self.up
    removeConstraint("movement_details", "battery_id")
    removeConstraint("movement_details", "charger_id")
    remove_column :movement_details, :battery_id
    remove_column :movement_details, :charger_id 
  end

  def self.down
  end
end
