class AddCostsToParts < ActiveRecord::Migration
  def self.up
    add_column :part_types, :cost, :integer
  end

  def self.down
    remove_column :part_types, :cost
  end
end
