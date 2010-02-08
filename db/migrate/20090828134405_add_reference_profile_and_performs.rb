class AddReferenceProfileAndPerforms < ActiveRecord::Migration
  def self.up

    Profile.transaction do

      attribs = Hash.new
      attribs[:description] = "defecto"
      attribs[:internal_tag] = "default"
      attribs[:has_data_scope] = false
      default_profile = Profile.new(attribs)

      if default_profile.save!

        Person.find(:all).each { |person|

          if person.performs == []
            Perform.create({ :person_id => person.id, :place_id => person.place_id, :profile_id => default_profile.id})
          end
        }

      end

    end

  end

  def self.down
  end
end
