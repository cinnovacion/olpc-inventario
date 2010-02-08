class AddColumnTypeToPlace < ActiveRecord::Migration
  extend DbUtil
  def self.up
    add_column :places, :place_type_id, :integer
    self.createConstraint("places", "place_type_id", "place_types")
  end

  def self.down
    self.removeConstraint("places", "place_type_id")
    remove_column :places, :place_type_id
  end
end
