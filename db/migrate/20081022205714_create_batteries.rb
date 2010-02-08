class CreateBatteries < ActiveRecord::Migration
  def self.up
    create_table :batteries do |t|
      t.string :serial_number , :limit => 100
      t.date :created_at
      t.integer :owner_id
      t.integer :shipment_arrival_id
    end
  end

  def self.down
    drop_table :batteries
  end
end
