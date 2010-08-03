class FixUnassignedLaptops < ActiveRecord::Migration
  def self.up
    # When it was developed, the assignments controller incorrrectly used 0
    # as the person ID value for an unassigned laptop. Fix up those instances.
    Assignment.find_all_by_destination_person_id(0).each { |a|
      a.destination_person_id = nil
      a.save!
    }
    Assignment.find_all_by_source_person_id(0).each { |a|
      a.source_person_id = nil
      a.save!
    }
    Laptop.find_all_by_assignee_id(0).each { |laptop|
      laptop.assignee_id = nil
      laptop.save!
    }
  end

  def self.down
  end
end
