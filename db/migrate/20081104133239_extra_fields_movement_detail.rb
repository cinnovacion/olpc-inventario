class ExtraFieldsMovementDetail < ActiveRecord::Migration

  def self.up
    add_column :movement_details, :description, :string, :limit => 100
    add_column :movement_details, :serial_number, :string, :limit => 100
  end

  def self.down
    remove_column :movement_details, :description
    remove_column :movement_details, :serial_number
  end

end
