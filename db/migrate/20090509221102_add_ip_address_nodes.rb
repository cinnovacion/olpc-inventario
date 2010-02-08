class AddIpAddressNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :ip_address, :string, :limit => 100
  end

  def self.down
    remove_column :nodes, :ip_address
  end
end
