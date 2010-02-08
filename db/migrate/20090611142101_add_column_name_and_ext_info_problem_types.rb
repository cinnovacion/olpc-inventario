class AddColumnNameAndExtInfoProblemTypes < ActiveRecord::Migration
  def self.up
    add_column :problem_types, :name, :string, :limit => 100
    add_column :problem_types, :extended_info, :string, :limit => 255
  end

  def self.down
    remove_column :problem_types, :name
    remove_column :problem_types, :extended_info
  end
end
