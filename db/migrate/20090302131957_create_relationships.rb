class CreateRelationships < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :relationships do |t|
      t.integer :person_id
      t.integer :to_person_id
      t.integer :profile_id
    end
    self.createConstraint("relationships", "person_id", "people")
    self.createConstraint("relationships", "to_person_id", "people")
    self.createConstraint("relationships", "profile_id", "profiles")
  end

  def self.down
    self.removeConstraint("relationships", "person_id")
    self.removeConstraint("relationships", "to_person_id")
    self.removeConstraint("relationships", "profile_id")
    drop_table :relationships
  end
end
