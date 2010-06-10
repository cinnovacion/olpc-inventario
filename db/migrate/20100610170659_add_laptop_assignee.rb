class AddLaptopAssignee < ActiveRecord::Migration
  def self.up
    add_column :laptops, :assignee_id, :integer
  end

  def self.down
    remove_column :laptops, :assignee_id
  end
end
