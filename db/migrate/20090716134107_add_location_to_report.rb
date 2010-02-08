class AddLocationToReport < ActiveRecord::Migration
  extend DbUtil
  def self.up
    add_column :problem_reports, :place_id, :integer
    self.createConstraint("problem_reports", "place_id", "places")

    ProblemReport.transaction do
      ProblemReport.find(:all).each { |report|
        report.place_id = report.laptop.owner.place.id
        report.save!
      }
    end

  end

  def self.down
    self.removeConstraint("problem_reports", "place_id")
    remove_column :problem_reports, :place_id
  end
end
