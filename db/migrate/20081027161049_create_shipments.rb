class CreateShipments < ActiveRecord::Migration
  def self.up
    create_table :shipments do |t|
      t.date :created_at
      t.date :arrived_at
      t.string :comment , :limit => 100
    end
  end

  def self.down
    drop_table :shipments
  end
end
