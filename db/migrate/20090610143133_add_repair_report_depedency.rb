class AddRepairReportDepedency < ActiveRecord::Migration
  def self.up
    add_column :problem_solutions, :problem_report_id, :integer
  end

  def self.down
    remove_column :problem_solutions, :problem_report_id
  end
end
