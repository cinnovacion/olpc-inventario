class AddReturnDateToMovement < ActiveRecord::Migration
  def self.up
    add_column :movements, :return_date, :date
  end

  def self.down
    remove_column :movements, :return_date
  end
end
