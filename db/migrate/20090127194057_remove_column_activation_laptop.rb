class RemoveColumnActivationLaptop < ActiveRecord::Migration
  def self.up
	remove_column(:laptops,:activation_id)
  end

  def self.down
	add_column(:laptops,:activation_id,:integer)
  end
end
