class DeletePlaceFromPeople < ActiveRecord::Migration
  def self.up
    remove_foreign_key :people, :places
    remove_column :people, :place_id
  end

  def self.down
    add_column :people, :place_id, :integer
    add_foreign_key :people, :places
  end
end
