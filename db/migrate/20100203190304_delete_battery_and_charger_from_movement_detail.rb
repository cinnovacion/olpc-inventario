class DeleteBatteryAndChargerFromMovementDetail < ActiveRecord::Migration
  def self.up
    remove_foreign_key :movement_details, :batteries
    remove_foreign_key :movement_details, :chargers
    remove_column :movement_details, :battery_id
    remove_column :movement_details, :charger_id 
  end

  def self.down
  end
end
