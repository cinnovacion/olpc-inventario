class CreatePerforms < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :performs do |t|
      t.integer :person_id
      t.integer :place_id
      t.integer :profile_id
    end
    self.createConstraint("performs", "person_id", "people")
    self.createConstraint("performs", "place_id", "places")
    self.createConstraint("performs", "profile_id", "profiles")
  end

  def self.down
    self.removeConstraint("performs", "person_id")
    self.removeConstraint("performs", "place_id")
    self.removeConstraint("performs", "profile_id")
    drop_table :performs
  end
end
