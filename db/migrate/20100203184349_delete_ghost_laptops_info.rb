class DeleteGhostLaptopsInfo < ActiveRecord::Migration
  def self.up
    remove_column :laptops, :is_ghost
  end

  def self.down
  end
end
