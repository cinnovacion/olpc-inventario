class CreateNotificationSubscribers < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :notification_subscribers do |t|
      t.integer :notification_id
      t.integer :person_id
      t.date    :created_at
    end

    self.createConstraint("notification_subscribers", "notification_id", "notifications")
    self.createConstraint("notification_subscribers", "person_id", "people")

  end

  def self.down

    self.removeConstraint("notification_subscribers", "notification_id")
    self.removeConstraint("notification_subscribers", "person_id")

    drop_table :notification_subscribers
  end
end
