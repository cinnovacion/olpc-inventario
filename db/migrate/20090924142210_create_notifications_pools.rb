class CreateNotificationsPools < ActiveRecord::Migration
  extend DbUtil
  
  def self.up
    create_table :notifications_pools do |t|

      t.integer :notification_id
      t.text :extended_data
      t.boolean :sent, :default => false
      t.integer :place_id
    end

    createConstraint("notifications_pools", "notification_id", "notifications")
    createConstraint("notifications_pools", "place_id", "places")
  end

  def self.down

    removeConstraint("notifications_pools", "notification_id")
    removeConstraint("notifications_pools", "place_id")

    drop_table :notifications_pools
  end
end
