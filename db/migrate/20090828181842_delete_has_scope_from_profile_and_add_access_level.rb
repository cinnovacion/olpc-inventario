class DeleteHasScopeFromProfileAndAddAccessLevel < ActiveRecord::Migration
  def self.up

    #Since now ALL the profile has data_scoping, this column has no meaning.
    remove_column :profiles, :has_data_scope

    #To fix many posible ambiguity problems we add a Access level priority to profiles
    add_column :profiles, :access_level, :integer, :default => 0

    Profile.reset_column_information

    profiles_tags = ["root","director","technician","teacher","student"]

    profiles_tags.reverse!.each_index { |index| 
      profile = Profile.find_by_internal_tag(profiles_tags[index])
      profile.access_level = (index+1)*100
      profile.save!
    }

  end

  def self.down

    remove_column :profiles, :access_level

  end
end
