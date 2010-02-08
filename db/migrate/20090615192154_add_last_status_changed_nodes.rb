class AddLastStatusChangedNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :last_status_change_at, :datetime
  end

  def self.down
    remove_column :nodes, :last_status_change_at
  end
end
