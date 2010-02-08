class AddRegisteredColumnLaptops < ActiveRecord::Migration
  def self.up
     add_column :laptops, :registered, :boolean, :default => 0
  end

  def self.down
    remove_column :laptops, :registered
  end
end
