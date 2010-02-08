class CreatePlaceDependencies < ActiveRecord::Migration
  extend DbUtil

  def self.up
    create_table :place_dependencies do |t|
      t.integer :descendant_id
      t.integer :ancestor_id
    end

    self.createConstraint("place_dependencies", "descendant_id", "places")
    self.createConstraint("place_dependencies", "ancestor_id", "places")

    PlaceDependency.transaction do

      Place.find(:all).each { |place|
        PlaceDependency.register_dependencies(place)
      }

    end

  end

  def self.down

    self.removeConstraint("place_dependencies", "descendant_id")
    self.removeConstraint("place_dependencies", "ancestor_id")

    drop_table :place_dependencies
  end

end
