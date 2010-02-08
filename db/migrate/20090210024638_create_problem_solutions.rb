class CreateProblemSolutions < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :problem_solutions do |t|
      t.integer :problem_type_id
      t.date :created_at
      t.integer :solved_by_person_id
      t.integer :src_part_id
      t.integer :dst_part_id
      t.string  :comment, :limit => 255
    end

  self.createConstraint("problem_solutions", "problem_type_id", "problem_types")
  self.createConstraint("problem_solutions", "solved_by_person_id", "people")
  self.createConstraint("problem_solutions", "src_part_id", "parts")
  self.createConstraint("problem_solutions", "dst_part_id", "parts")

  end

  def self.down
    drop_table :problem_solutions
  end
end
