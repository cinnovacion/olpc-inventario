class AddAssignmentTracking < ActiveRecord::Migration
  def self.up
    create_table "assignments", :force => true do |t|
      t.date    "created_at"
      t.date    "date_assigned"
      t.time    "time_assigned"
      t.integer "source_person_id"
      t.integer "destination_person_id"
      t.integer "laptop_id"
      t.text    "comment"
    end

    add_index "assignments", ["destination_person_id"], :name => "assignments_destination_person_id_fk"
    add_index "assignments", ["source_person_id"], :name => "assignments_source_person_id_fk"
    add_index "assignments", ["laptop_id"], :name => "assignments_laptop_id_fk"
  end

  def self.down
    drop_table :assignments
  end
end
