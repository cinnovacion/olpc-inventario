class CreatePermissions < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :permissions do |t|
      t.string :name, :limit => 100
      t.integer :controller_id
    end

  self.createConstraint("permissions", "controller_id", "controllers")

  end

  def self.down
    self.removeConstraint("permissions", "controller_id")
    drop_table :permissions
  end
end
