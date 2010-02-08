class AddIsGhostDeviceToDevices < ActiveRecord::Migration
  def self.up

    add_column :laptops, :is_ghost, :boolean, :default => false
    add_column :batteries, :is_ghost, :boolean, :default => false
    add_column :chargers, :is_ghost, :boolean, :default => false
  end

  def self.down

    remove_column :laptops, :is_ghost
    remove_column :batteries, :is_ghost
    remove_column :chargers, :is_ghost
  end
end
