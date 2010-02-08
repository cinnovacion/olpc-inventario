class CreateModels < ActiveRecord::Migration
  def self.up
    create_table :models do |t|
      t.date :created_at
      t.string :name , :limit => 100
      t.text :description
    end
  end

  def self.down
    drop_table :models
  end
end
