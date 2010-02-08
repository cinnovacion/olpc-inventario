class CreatePeopleProfiles < ActiveRecord::Migration
  def self.up
    create_table :people_profiles, :id => false do |t|
      t.integer :person_id
      t.integer :profile_id
    end
  end

  def self.down
  end
end
