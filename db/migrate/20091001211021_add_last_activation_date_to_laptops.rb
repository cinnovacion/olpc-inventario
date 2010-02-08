class AddLastActivationDateToLaptops < ActiveRecord::Migration
  def self.up

    add_column :laptops, :last_activation_date, :date, :default => nil
  end

  def self.down
  
   remove_column :laptops, :last_activation_date
  end
end
