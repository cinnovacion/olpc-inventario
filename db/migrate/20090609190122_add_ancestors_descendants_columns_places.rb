class AddAncestorsDescendantsColumnsPlaces < ActiveRecord::Migration
  def self.up
    add_column :places, :ancestors_ids, :text
    add_column :places, :descendants_ids, :text
  end

  def self.down
    remove_column :places, :ancestors_ids
    remove_column :places, :descendants_ids
  end
end
