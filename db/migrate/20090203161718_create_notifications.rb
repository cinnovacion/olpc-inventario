class CreateNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.string :name, :limit => 100
      t.string :description, :limit => 255
      t.string :internal_tag, :limit => 100
      t.boolean :active, :default => 0
    end
  end

  def self.down
    drop_table :notifications
  end
end
