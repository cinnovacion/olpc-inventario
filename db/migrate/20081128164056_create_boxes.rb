class CreateBoxes < ActiveRecord::Migration
  def self.up
    create_table :boxes do |t|
      t.integer :shipment_id
      t.integer :place_id
      t.string :serial_number, :limit => 100
    end
  end

  def self.down
    drop_table :boxes
  end
end
