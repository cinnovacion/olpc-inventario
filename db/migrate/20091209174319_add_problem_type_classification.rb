class AddProblemTypeClassification < ActiveRecord::Migration
  def self.up
    add_column :problem_types, :is_hardware, :boolean, :default => false
  end

  def self.down
    remove_column :problem_types, :is_hardware
  end
end
