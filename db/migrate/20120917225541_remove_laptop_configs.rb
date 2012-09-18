class RemoveLaptopConfigs < ActiveRecord::Migration
  def self.up
    drop_table :laptop_configs
  end

  def self.down
  end
end
