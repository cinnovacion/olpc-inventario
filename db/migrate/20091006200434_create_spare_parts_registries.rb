class CreateSparePartsRegistries < ActiveRecord::Migration

  extend DbUtil
  def self.up
    create_table :spare_parts_registries do |t|

      t.date :created_at
      t.integer :amount
      t.integer :part_type_id
      t.integer :person_id
      t.integer :owner_id
      t.integer :place_id
      t.string :device_serial, :limit => 255
    end

    createConstraint("spare_parts_registries", "part_type_id", "part_types")
    createConstraint("spare_parts_registries", "person_id", "people")
    createConstraint("spare_parts_registries", "owner_id", "people")
    createConstraint("spare_parts_registries", "place_id", "places") 
  end

  def self.down

    removeConstraint("spare_parts_registries", "part_type_id")
    removeConstraint("spare_parts_registries", "person_id")
    removeConstraint("spare_parts_registries", "owner_id")
    removeConstraint("spare_parts_registries", "place_id")

    drop_table :spare_parts_registries
  end
end
