class CreateBoxMovements < ActiveRecord::Migration
  def self.up
    create_table :box_movements do |t|
      t.date :created_at
      t.date :date_moved_at
      t.time :time_moved_at
      t.integer :src_place_id
      t.integer :src_person_id
      t.integer :dst_place_id
      t.integer :dst_person_id
      t.integer :authorized_person_id
    end
  end

  def self.down
    drop_table :box_movements
  end
end
