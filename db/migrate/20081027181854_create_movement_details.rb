class CreateMovementDetails < ActiveRecord::Migration
  def self.up
    create_table :movement_details do |t|
      t.integer :movement_id
      t.integer :laptop_id
      t.integer :battery_id
      t.integer :charger_id
      t.integer :movement_type_id
    end
  end

  def self.down
    drop_table :movement_details
  end
end
