class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.date :created_at
      t.string :name, :limit => 100
      t.binary :file, :limit => 1.megabyte
    end
  end

  def self.down
    drop_table :images
  end
end
