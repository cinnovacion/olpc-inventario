class CreateAnswers < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :answers do |t|
      t.integer :quiz_id
      t.integer :person_id
      t.date :created_at
      t.date :answered_at
    end
    self.createConstraint("answers", "quiz_id", "quizzes")
    self.createConstraint("answers", "person_id", "people")
  end

  def self.down
    self.removeConstraint("answers", "quiz_id")
    self.removeConstraint("answers", "person_id")
    drop_table :answers
  end
end
