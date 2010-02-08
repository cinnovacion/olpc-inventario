class CreateLots < ActiveRecord::Migration
  extend DbUtil
  def self.up
    create_table :lots do |t|
      t.date  :created_at
      t.date  :delivery_date
      t.integer  :person_id
      t.boolean  :delivered
      t.integer  :boxes_number
    end
    self.createConstraint("lots", "person_id", "people")
  end

  def self.down
    self.removeConstraint("lots", "person_id")
    drop_table :lots
  end
end
