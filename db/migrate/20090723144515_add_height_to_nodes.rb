class AddHeightToNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :height, :string, :limit => 100
  end

  def self.down
    remove_column :nodes, :height
  end
end
