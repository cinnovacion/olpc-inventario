class AddZoomNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :zoom, :integer
  end

  def self.down
    remove_column :nodes, :zoom
  end
end
