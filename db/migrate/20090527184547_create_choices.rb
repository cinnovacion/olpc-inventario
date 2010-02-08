class CreateChoices < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :choices do |t|
      t.integer :answer_id
      t.integer :question_id
      t.integer :option_id
      t.string :comment, :limit => 255
    end
    self.createConstraint("choices", "answer_id", "answers")
    self.createConstraint("choices", "question_id", "questions")
    self.createConstraint("choices", "option_id", "options")
  end

  def self.down
    self.removeConstraint("choices", "answer_id")
    self.removeConstraint("choices", "question_id")
    self.removeConstraint("choices", "option_id")
    drop_table :choices
  end
end
