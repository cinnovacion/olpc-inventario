class AddLaptopAssigneeIndex < ActiveRecord::Migration
  def self.up
    add_index "laptops", ["assignee_id"], :name => "laptops_assignee_id_fk"
  end

  def self.down
    remove_index :laptops, :name => "laptops_assignee_id_fk"
  end
end
