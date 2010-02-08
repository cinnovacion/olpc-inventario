class CreateNodeTypes < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :node_types do |t|
      t.string :name, :limit => 100
      t.string :description, :limit => 255
      t.string :internal_tag, :limit => 100
      t.integer :image_id
    end
    self.createConstraint("node_types", "image_id", "images")
  end

  def self.down
      self.removeConstraint("node_types", "image_id")
    drop_table :node_types
  end
end
