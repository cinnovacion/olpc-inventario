class DeletePartAssociationsFromProblemSolutions < ActiveRecord::Migration
  extend DbUtil
  def self.up
    removeConstraint("problem_solutions", "src_part_id")
    removeConstraint("problem_solutions", "dst_part_id")
    remove_column :problem_solutions, :src_part_id
    remove_column :problem_solutions, :dst_part_id
  end

  def self.down
  end
end
