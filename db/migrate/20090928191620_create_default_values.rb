class CreateDefaultValues < ActiveRecord::Migration
  def self.up
    create_table :default_values do |t|

      t.string :key, :limit => 100
      t.text :value
    end
  end

  def self.down
    drop_table :default_values
  end
end
