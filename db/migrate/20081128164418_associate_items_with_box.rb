class AssociateItemsWithBox < ActiveRecord::Migration
  def self.up
    add_column :laptops, :box_id, :integer
    add_column :chargers, :box_id, :integer
    add_column :batteries, :box_id, :integer
  end

  def self.down
    remove_column :laptops, :box_id
    remove_column :chargers, :box_id
    remove_column :batteries, :box_id
  end
end
