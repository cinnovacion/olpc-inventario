class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :event_type_id
      t.datetime :created_at
      t.string :reporter_info, :limit => 100
      t.text :extended_info
    end
  end

  def self.down
    drop_table :events
  end
end
