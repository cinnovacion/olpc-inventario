class CreatePartMovementTypes < ActiveRecord::Migration
  def self.up
    create_table :part_movement_types do |t|
      t.string :name, :limit => 100
      t.string :description, :limit => 255
      t.string :internal_tag, :limit => 100
      t.boolean :direction, :default => false
    end
  end

  def self.down
    drop_table :part_movement_types
  end
end
