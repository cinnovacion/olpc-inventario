class CreateBankDeposits < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :bank_deposits do |t|

      t.integer :problem_solution_id
      t.string :deposit, :limit => 100
      t.float :amount, :default => 0
      t.date :created_at
      t.date :deposited_at
      t.string :bank, :limit => 100
    end

	  self.createConstraint("bank_deposits", "problem_solution_id", "problem_solutions")
  end

  def self.down
    self.removeConstraint("bank_deposits", "problem_solution_id")
    drop_table :bank_deposits
  end

end
