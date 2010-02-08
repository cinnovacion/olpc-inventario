class CreateSolutionTypes < ActiveRecord::Migration
  def self.up
    create_table :solution_types do |t|
      t.string :name, :limit => 100
      t.string :description, :limit => 255
      t.string :extended_info, :limit => 255
      t.string :internal_tag, :limit => 100
    end
  end

  def self.down
    drop_table :solution_types
  end
end
