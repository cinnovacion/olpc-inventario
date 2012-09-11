class DeletePartTypeFromSolutionType < ActiveRecord::Migration
  def self.up
    remove_foreign_key :solution_types, :part_types
    remove_column :solution_types, :part_type_id
  end

  def self.down
    add_column :solution_types, :part_type_id, :integer
    add_foreign_key :solution_types, :part_types
  end
end
