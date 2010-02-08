class CreateTeaches < ActiveRecord::Migration
  def self.up
    create_table :teaches do |t|
      t.integer :person_id
      t.integer :place_id
    end
  end

  def self.down
    drop_table :teaches
  end
end
