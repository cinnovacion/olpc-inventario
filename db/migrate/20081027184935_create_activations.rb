class CreateActivations < ActiveRecord::Migration
  def self.up
    create_table :activations do |t|
      t.date :created_at
      t.date :date_activated_at
      t.time :time_activated_at
      t.string :comment, :string => 200
      t.integer :laptop_id
      t.integer :person_activated_id
    end
  end

  def self.down
    drop_table :activations
  end
end
