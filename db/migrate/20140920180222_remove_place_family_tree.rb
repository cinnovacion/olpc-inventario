class RemovePlaceFamilyTree < ActiveRecord::Migration
  def up
    remove_column :places, :ancestors_ids
    remove_column :places, :descendants_ids
  end

  def down
  end
end
