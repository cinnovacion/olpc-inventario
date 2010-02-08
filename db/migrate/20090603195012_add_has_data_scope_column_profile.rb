class AddHasDataScopeColumnProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :has_data_scope, :boolean, :default => 1
  end

  def self.down
    remove_column :profiles, :has_data_scope
  end
end
