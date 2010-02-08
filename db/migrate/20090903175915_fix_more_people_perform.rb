class FixMorePeoplePerform < ActiveRecord::Migration
  def self.up

    Place.transaction do
    Perform.transaction do

      # Paraguay place type.
      paraguay_place = Place.find_by_name("Paraguay")
      country_place_type = PlaceType.find_by_internal_tag("country")
      paraguay_place.place_type_id = country_place_type.id
      paraguay_place.save
      
      # Fix some important users performs
      rolfi_person = Person.find_by_id_document("1527205")
      root_profile = Profile.find_by_internal_tag("root")
      Perform.destroy(rolfi_person.performs)
      Perform.create({ :place_id => paraguay_place.id, :person_id => rolfi_person.id, :profile_id => root_profile.id })

      caacupe_place = Place.find_by_name("Caacupe")
      fernando_person = Person.find_by_id_document("2357511")
      technician_profile = Profile.find_by_internal_tag("technician")
      Perform.destroy(fernando_person.performs)
      Perform.create({ :place_id => caacupe_place.id, :person_id => fernando_person.id, :profile_id => technician_profile.id })

      caacupe_place = Place.find_by_name("Caacupe")
      pyedu_cordillera_person = Person.find_by_id_document("3")
      root_profile = Profile.find_by_internal_tag("root")
      Perform.destroy(pyedu_cordillera_person.performs)
      Perform.create({ :place_id => caacupe_place.id, :person_id => pyedu_cordillera_person.id, :profile_id => root_profile.id })

    end
    end

  end

  def self.down
  end
end
