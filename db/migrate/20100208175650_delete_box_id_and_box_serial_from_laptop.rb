class DeleteBoxIdAndBoxSerialFromLaptop < ActiveRecord::Migration
  def self.up
    remove_column :laptops, :box_id
    remove_column :laptops, :box_serial_number
  end

  def self.down
  end
end
