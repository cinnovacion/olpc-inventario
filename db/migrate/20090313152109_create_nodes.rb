class CreateNodes < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :nodes do |t|
      t.string :name, :limit => 100
      t.string :lat, :limit => 100
      t.string :lng, :limit => 100
      t.integer :node_type_id
      t.integer :place_id
    end
    self.createConstraint("nodes", "node_type_id", "node_types")
    self.createConstraint("nodes", "place_id", "places")
  end

  def self.down
    self.removeConstraint("nodes", "node_type_id")
    self.removeConstraint("nodes", "place_id")
    drop_table :nodes
  end
end
