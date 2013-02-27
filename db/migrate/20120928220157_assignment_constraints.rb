class AssignmentConstraints < ActiveRecord::Migration
  def self.up
    # Fix up existing data - must be done before adding foreign keys.
    # Use direct SQL to avoid saving audits and updating timestamps
    Assignment.includes(:destination_person).each { |a|
      next if a.destination_person_id.nil?
      next if !a.destination_person.nil?
      ActiveRecord::Base.connection.execute("UPDATE assignments SET destination_person_id = NULL WHERE id=#{a.id}")
    }
    Assignment.includes(:source_person).each { |a|
      next if a.source_person_id.nil?
      next if !a.source_person.nil?
      ActiveRecord::Base.connection.execute("UPDATE assignments SET source_person_id = NULL WHERE id=#{a.id}")
    }

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
