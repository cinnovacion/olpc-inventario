class AddColumnNumberShipment < ActiveRecord::Migration
  def self.up
    add_column :shipments, :shipment_number, :string, :limit => 255
  end

  def self.down
    remove_column :shipments, :shipment_number
  end
end
