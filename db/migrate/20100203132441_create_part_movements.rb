class CreatePartMovements < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :part_movements do |t|
      t.integer :part_movement_type_id
      t.integer :part_type_id
      t.integer :amount
      t.integer :place_id
      t.integer :person_id
      t.datetime :created_at
    end

    createConstraint("part_movements", "part_movement_type_id", "part_movement_types")
    createConstraint("part_movements", "part_type_id", "part_types")
    createConstraint("part_movements", "place_id", "places")
    createConstraint("part_movements", "person_id", "people")
  end

  def self.down
    drop_table :part_movements
  end
end
