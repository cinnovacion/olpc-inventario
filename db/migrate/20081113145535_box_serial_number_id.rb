class BoxSerialNumberId < ActiveRecord::Migration
  def self.up

    add_column :laptops, :box_serial_number, :string, :limit => 100
    add_column :chargers, :box_serial_number, :string, :limit => 100
    add_column :batteries, :box_serial_number, :string, :limit => 100

  end

  def self.down

    remove_column :laptops, :box_serial_number
    remove_column :chargers, :box_serial_number
    remove_column :batteries, :box_serial_number

  end

end
