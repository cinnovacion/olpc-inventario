class CreatePlaces < ActiveRecord::Migration
  def self.up
    create_table :places do |t|
      t.date :created_at
      t.string :name, :limit => 100
      t.text :description
      t.integer :place_id
    end
  end

  def self.down
    drop_table :places
  end
end
