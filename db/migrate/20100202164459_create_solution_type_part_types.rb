class CreateSolutionTypePartTypes < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :solution_type_part_types do |t|
      t.integer :solution_type_id, :null => false
      t.integer :part_type_id, :null => false
    end

    createConstraint("solution_type_part_types", "part_type_id", "part_types")
    createConstraint("solution_type_part_types", "solution_type_id", "solution_types")
  end

  def self.down
    drop_table :solution_type_part_types
  end
end
