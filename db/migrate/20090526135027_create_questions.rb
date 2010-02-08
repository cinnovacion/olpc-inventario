class CreateQuestions < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :questions do |t|
      t.string :question, :limit => 255
      t.integer :quiz_id
    end
    self.createConstraint("questions", "quiz_id", "quizzes")
  end

  def self.down
    self.removeConstraint("questions", "quiz_id")
    drop_table :questions
  end
end
