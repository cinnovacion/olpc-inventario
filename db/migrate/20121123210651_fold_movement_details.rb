class FoldMovementDetails < ActiveRecord::Migration
  def self.up
    # FIXME need to carefully test this migration
    Movement.transaction do

    # Add necessary columns to movements table
    add_column :movements, :laptop_id, :integer
    add_column :movements, :returned, :boolean, default: false

    # Migrate info from movement_details table
    sql = "UPDATE movements LEFT JOIN movement_details ON (movement_details.movement_id = movements.id) SET movements.returned=movement_details.returned, movements.laptop_id=movement_details.laptop_id"
    ActiveRecord::Base.connection.execute(sql)

    # Create indexes and integrity
    add_index :movements, [:laptop_id]
    add_foreign_key :movements, :laptops

    # Destroy movement_details table
    remove_foreign_key :movement_details, :laptops
    remove_foreign_key :movement_details, :movements
    drop_table :movement_details

    # Another cleanup
    remove_foreign_key :movements, column: "responsible_person_id"
    remove_column :movements, :responsible_person_id
    end
  end

  def self.down
    raise "Can't revert"
  end
end
