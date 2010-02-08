class AddColumnReturnMovementDetail < ActiveRecord::Migration
  def self.up
    add_column :movement_details,:returned,:boolean, :default => false
  end

  def self.down
    remove_column :movement_details,:returned
  end
end
