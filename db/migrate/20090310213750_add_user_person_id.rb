class AddUserPersonId < ActiveRecord::Migration
  extend DbUtil
  def self.up
    add_column :users, :person_id, :integer
    self.createConstraint("users", "person_id", "people")
  end

  def self.down
    self.removeConstraint("users", "person_id")
    remove_column :users, :person_id
  end
end
