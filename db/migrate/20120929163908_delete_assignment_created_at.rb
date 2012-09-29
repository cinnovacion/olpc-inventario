class DeleteAssignmentCreatedAt < ActiveRecord::Migration
  def self.up
    # Unused field, duplicate of date_assigned
    remove_column :assignments, :created_at
  end

  def self.down
    add_column :assignments, :created_at, :date
  end
end
