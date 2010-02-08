class CreateSectionDetails < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :section_details do |t|
      t.integer :lot_id
      t.integer :place_id
    end
    self.createConstraint("section_details", "lot_id", "lots")
    self.createConstraint("section_details", "place_id", "places")
  end

  def self.down
    self.removeConstraint("section_details", "lot_id")
    self.removeConstraint("section_details", "place_id")
    drop_table :section_details
  end
end
