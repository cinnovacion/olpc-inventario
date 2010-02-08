class ModifyDateAndTimeOnStatusChange < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE status_changes MODIFY date_created_at DATE NULL"
    execute "ALTER TABLE status_changes MODIFY time_created_at TIME NULL"
  end

  def self.down
  end
end
