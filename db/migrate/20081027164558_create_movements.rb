class CreateMovements < ActiveRecord::Migration
  def self.up
    create_table :movements do |t|
      t.date :created_at
      t.date :date_moved_at
      t.time :time_moved_at
      t.integer :responsible_person_id
      t.integer :source_person_id
      t.integer :destination_person_id
      t.text :comment
    end
  end

  def self.down
    drop_table :movements
  end
end
