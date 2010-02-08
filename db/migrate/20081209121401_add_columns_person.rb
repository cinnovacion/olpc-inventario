class AddColumnsPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :position, :string, :limit => 50
    add_column :people, :school_name, :string, :limit => 50
  end

  def self.down
    remove_column :people, :position
    remove_column :people, :school_name
  end
end
