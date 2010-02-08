class ProblemSolutionAddSolutionType < ActiveRecord::Migration
  extend DbUtil
  def self.up
    self.removeConstraint("problem_solutions", "problem_type_id")
    remove_column :problem_solutions, :problem_type_id
    add_column :problem_solutions, :solution_type_id, :integer
    self.createConstraint("problem_solutions", "solution_type_id", "solution_types")
  end

  def self.down
    self.removeConstraint("problem_solutions", "solution_type_id")
    remove_column :problem_solutions, :solution_type_id
    add_column :problem_solutions, :problem_type_id, :integer
    self.createConstraint("problem_solutions", "problem_type_id", "problem_types")
  end
end
