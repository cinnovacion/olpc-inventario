class AddProblemSolutionProblemReportConstraint < ActiveRecord::Migration
  def self.up
    add_foreign_key :problem_solutions, :problem_reports
  end

  def self.down
    remove_foreign_key :problem_solutions, :problem_reports
  end
end
