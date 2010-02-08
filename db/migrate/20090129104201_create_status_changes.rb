class CreateStatusChanges < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :status_changes do |t|
	t.integer :previous_state_id
	t.integer :new_state_id
	t.integer :laptop_id
	t.integer :battery_id
	t.integer :charger_id
	t.integer :date_created_at
	t.integer :time_created_at
    end

    self.createConstraint("status_changes", "previous_state_id", "statuses")
    self.createConstraint("status_changes", "new_state_id", "statuses")
    self.createConstraint("status_changes", "laptop_id", "laptops")
    self.createConstraint("status_changes", "battery_id", "batteries")
    self.createConstraint("status_changes", "charger_id", "chargers")

  end

  def self.down
    drop_table :status_changes
  end
end
