class CreateBoxMovementDetails < ActiveRecord::Migration
  def self.up
    create_table :box_movement_details do |t|
      t.integer :box_movement_id
      t.integer :box_id
    end
  end

  def self.down
    drop_table :box_movement_details
  end
end
