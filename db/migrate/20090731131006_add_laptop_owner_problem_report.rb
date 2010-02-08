class AddLaptopOwnerProblemReport < ActiveRecord::Migration
  extend DbUtil
  def self.up

    add_column :problem_reports, :owner_id, :integer
    self.createConstraint("problem_reports", "owner_id", "people")

    ProblemReport.transaction do

      ProblemReport.find(:all).each { |problem_report|
        problem_report.owner_id = problem_report.laptop.owner_id
        problem_report.save!
      }

    end
  end

  def self.down

    self.removeConstraint("problem_reports", "owner_id")
    remove_column :problem_reports, :owner_id

  end
end
