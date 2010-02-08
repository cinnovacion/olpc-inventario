class CreateQuizzes < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :quizzes do |t|
      t.string :title, :limit => "255"
      t.date :created_at
      t.integer :person_id
    end
    self.createConstraint("quizzes", "person_id", "people")
  end

  def self.down
    self.removeConstraint("quizzes", "person_id")
    drop_table :quizzes
  end
end
