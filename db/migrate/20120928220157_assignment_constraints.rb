class AssignmentConstraints < ActiveRecord::Migration
  def self.up
    add_foreign_key :assignments, :people, :column => "destination_person_id"
    add_foreign_key :assignments, :people, :column => "source_person_id"
    add_foreign_key :assignments, :laptops
  end

  def self.down
    remove_foreign_key :assignments, :people, :column => "destination_person_id"
    remove_foreign_key :assignments, :people, :column => "source_person_id"
    remove_foreign_key :assignments, :laptops
  end
end
