class CreateProblemReports < ActiveRecord::Migration
  def self.up
    create_table :problem_reports do |t|
      t.integer :problem_type_id
      t.integer :person_id
      t.integer :laptop_id
      t.date :created_at
      t.boolean :solved, :default => 0
      t.string :comment, :limit => 255
    end
  end

  def self.down
    drop_table :problem_reports
  end
end
