class DeletePartAssociationsFromProblemSolutions < ActiveRecord::Migration
  def self.up
    remove_foreign_key :problem_solutions, :column => 'src_part_id'
    remove_foreign_key :problem_solutions, :column => 'dst_part_id'
    remove_column :problem_solutions, :src_part_id
    remove_column :problem_solutions, :dst_part_id
  end

  def self.down
  end
end
