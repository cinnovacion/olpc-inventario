class DeleteOldTables < ActiveRecord::Migration
  @dropable_tables =[
    "activations",
    "answers", 
    "batteries", 
    "box_movement_details",
    "box_movements",
    "boxes",
    "choices",
    "copia",
    "chargers",
    "options",
    "parts",
    "people_profiles",
    "questions",
    "quizzes",
    "relationships",
    "teaches"
  ]

  def self.up
    remove_foreign_key :choices, :answers
    remove_foreign_key :parts, :batteries
    remove_foreign_key :status_changes, :batteries
    remove_foreign_key :box_movement_details, :box_movements
    remove_foreign_key :chargers, :boxes
    remove_foreign_key :laptops, :boxes
    remove_foreign_key :parts, :chargers
    remove_foreign_key :status_changes, :chargers

    @dropable_tables.each { |dropable_table|
      drop_table dropable_table.to_sym
    }
  end
end
