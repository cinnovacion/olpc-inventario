class CreateConnectionEvents < ActiveRecord::Migration
  def up
    create_table :connection_events do |t|
      t.integer :laptop_id, null: false
      t.datetime :connected_at, null: false
      t.boolean :stolen, default: false
      t.string :ip_address, limit: 64
      t.string :vhash, limit: 64
      t.integer :free_space
    end

    add_foreign_key :connection_events, :laptops
    add_index :connection_events, [:laptop_id, :connected_at], unique: true
  end

  def down
    drop_table :connection_events
  end
end
