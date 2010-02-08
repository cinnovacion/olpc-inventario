class AddLastUpdateTimeNodes < ActiveRecord::Migration
  def self.up
    add_column :nodes, :last_update_at, :datetime
  end

  def self.down
    remove_column :nodes, :last_update_at
  end
end
