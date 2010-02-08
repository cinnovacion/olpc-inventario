class AddColumnSolvedAtProblemReports < ActiveRecord::Migration
  def self.up
    add_column :problem_reports, :solved_at, :datetime

    ProblemSolution.find(:all).each { |solution|
      problem_report = solution.problem_report
      problem_report.solved_at = solution.created_at
      problem_report.save
    }

  end

  def self.down
    remove_column :problem_reports, :solved_at
  end
end
