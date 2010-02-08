class UserFixAdmin < ActiveRecord::Migration
  def self.up
    user = User.find_by_usuario("Admin")
    person = Person.find_by_name("Paraguay Educa")
    profile = Profile.find_by_internal_tag("root")
    if (user and  person and profile)
      user.person_id = person.id
      person.profiles << profile if !person.profiles.include?(profile)
      user.save!
    end
  end

  def self.down
  end
end
