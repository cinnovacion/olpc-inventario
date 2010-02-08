class DeletePlaceFromPeople < ActiveRecord::Migration
  extend DbUtil
  def self.up
    removeConstraint("people", "place_id")
    remove_column :people, :place_id
  end

  def self.down
    add_column :people, :place_id, :integer
    createConstraint("people", "place_id", "places")
  end
end
