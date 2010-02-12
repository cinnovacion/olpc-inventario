class AddProblemSolutionProblemReportConstraint < ActiveRecord::Migration
  extend DbUtil
  def self.up
    breaking_rules()
    createConstraint("problem_solutions", "problem_report_id", "problem_reports")
  end

  def self.down
    removeConstraint("problem_solutions", "problem_report_id")
  end

  #Only for this time.
  def breaking_rules

    ProblemSolution.all.each { |problem_solution|

      #This happened because there was no control or constraint
      if !problem_solution.problem_report
        BankDeposit.delete(problem_solution.bank_deposits.collect(&:id))
        ProblemSolution.delete(problem_solution.id)
      end
    } 
  end

end
