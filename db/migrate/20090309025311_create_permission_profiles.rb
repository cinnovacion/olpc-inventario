class CreatePermissionProfiles < ActiveRecord::Migration
  def self.up
    create_table :permissions_profiles, :id => false do |t|
      t.integer :permission_id
      t.integer :profile_id
    end
  end

  def self.down
    drop_table :permissions_profiles
  end
end
