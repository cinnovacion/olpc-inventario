class AddOnDeviceSerialPart < ActiveRecord::Migration
  def self.up
    add_column :parts, :on_device_serial, :string, :limit => 100

    Part.transaction do
      Part.find(:all).each { |part|
        part.on_device_serial = part.getParentSerial
        part.save!
      }
    end

  end

  def self.down
    remove_column :parts, :on_device_serial
  end
end
