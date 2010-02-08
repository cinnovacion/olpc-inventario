class CreateChargers < ActiveRecord::Migration
  def self.up
    create_table :chargers do |t|
      t.string :serial_number , :limit => 100
      t.date :created_at
      t.integer :owner_id
      t.integer :shipment_arrival_id
    end
  end

  def self.down
    drop_table :chargers
  end
end
