class CreateLaptops < ActiveRecord::Migration
  def self.up

    create_table :laptops do |t|
      t.string :serial_number , :limit => 100
      t.date :created_at
      t.string :build_version, :limit => 100
      t.integer :model_id
      t.integer :shipment_arrival_id
      t.integer :activation_id
      t.integer :owner_id
    end

  end
 
  def self.down
    drop_table :laptops
  end
end
