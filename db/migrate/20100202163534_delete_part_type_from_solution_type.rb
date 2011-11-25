require 'lib/db_util'

class DeletePartTypeFromSolutionType < ActiveRecord::Migration
  extend DbUtil

  def self.up
    removeConstraint("solution_types", "part_type_id")
    remove_column :solution_types, :part_type_id
  end

  def self.down
    add_column :solution_types, :part_type_id, :integer
    createConstraint("solution_type", "part_type_id", "part_types")
  end
end
