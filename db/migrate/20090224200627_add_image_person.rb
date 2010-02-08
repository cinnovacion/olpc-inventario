class AddImagePerson < ActiveRecord::Migration
  extend DbUtil
  def self.up
    add_column :people, :image_id, :integer
    self.createConstraint("people", "image_id", "images")
  end

  def self.down
    self.removeConstraint("people", "image_id")
    remove_column :people, :image_id
  end
end
