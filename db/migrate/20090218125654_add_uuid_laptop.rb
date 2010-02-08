class AddUuidLaptop < ActiveRecord::Migration
  def self.up
     add_column :laptops,:uuid,:string, :limit => 255
  end

  def self.down
    remove_column :laptops,:uuid
  end
end
