class CreatePartMovements < ActiveRecord::Migration
  def self.up
    create_table :part_movements do |t|
      t.integer :part_movement_type_id
      t.integer :part_type_id
      t.integer :amount
      t.integer :place_id
      t.integer :person_id
      t.datetime :created_at
    end

    add_foreign_key :part_movements, :part_movement_types
    add_foreign_key :part_movements, :part_types
    add_foreign_key :part_movements, :people
    add_foreign_key :part_movements, :places
  end

  def self.down
    drop_table :part_movements
  end
end
