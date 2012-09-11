class CreateSolutionTypePartTypes < ActiveRecord::Migration
  def self.up
    create_table :solution_type_part_types do |t|
      t.integer :solution_type_id, :null => false
      t.integer :part_type_id, :null => false
    end

    add_foreign_key :solution_type_part_types, :solution_types
    add_foreign_key :solution_type_part_types, :part_types
  end

  def self.down
    drop_table :solution_type_part_types
  end
end
