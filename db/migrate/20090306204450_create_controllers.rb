class CreateControllers < ActiveRecord::Migration
  def self.up
    create_table :controllers do |t|
      t.string :name, :limit => 100
    end
  end

  def self.down
    drop_table :controllers
  end
end
