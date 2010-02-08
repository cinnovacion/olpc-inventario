class CreateOptions < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :options do |t|
      t.string :option, :limit => 255
      t.boolean :correct, :default => 0
      t.integer :question_id
    end
    self.createConstraint("options", "question_id", "questions")
  end

  def self.down
    self.removeConstraint("options", "question_id")
    drop_table :options
  end
end
