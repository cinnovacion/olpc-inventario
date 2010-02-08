class FixPeoplePerforms < ActiveRecord::Migration
  def self.up

    Person.transaction do
    Profile.transaction do
    Perform.transaction do

    # Fixing our main user performs.
    developer_profile = Profile.find_by_internal_tag("developer")
    developer_profile.access_level = Profile.highest(Profile.all).access_level+100
    developer_profile.save

    pyedu_person = Person.find_by_id_document("1")
    paraguay_place = Place.find_by_name("Paraguay")

    Perform.create({ :place_id => paraguay_place.id, :person_id => pyedu_person.id, :profile_id => developer_profile.id })


    # Fixing some political stuff.
    director_profile = Profile.find_by_internal_tag("director")
    technician_profile = Profile.find_by_internal_tag("technician")
    director_profile.access_level = technician_profile.access_level
    director_profile.save
    

    #Fixing problems with old users performs.
    Person.all.each { |person|
    
      performs = person.performs.map { |perform| [perform.place_id, perform.profile_id] }
      if !Perform.check(pyedu_person, performs)

        highest_place = Place.highest(Place.find(:all, :conditions => ["places.id in (?)", performs.map { |pf| pf[0] } ] ) )
        highest_profile = Profile.highest(Profile.find(:all, :conditions => ["profiles.id in (?)", performs.map { |pf| pf[1] } ] ) )
        Perform.destroy(person.performs)
        Perform.create({ :place_id => highest_place.id, :person_id => person.id, :profile_id => highest_profile.id })    

      end

    }

    #Fixing problems with external systems users.
    caacupe_place = Place.find_by_name("Caacupe")

    student_updater_person = Person.find_by_id_document("tch001")
    teacher_profile = Profile.find_by_internal_tag("teacher")
    Perform.destroy(student_updater_person.performs)
    Perform.create({ :place_id => caacupe_place.id, :person_id => student_updater_person.id, :profile_id => teacher_profile.id })     
    
    leases_person = Person.find_by_id_document("tch002")
    leases_profile = Profile.find_by_internal_tag("extern_system")
    Perform.destroy(leases_person.performs)
    Perform.create({ :place_id => caacupe_place.id, :person_id => leases_person.id, :profile_id => leases_profile.id }) 

    network_control_person = Person.find_by_id_document("tch003")
    network_control_profile = Profile.find_by_internal_tag("network_control")
    Perform.destroy(network_control_person.performs)
    Perform.create({ :place_id => caacupe_place.id, :person_id => network_control_person.id, :profile_id => network_control_profile.id }) 

    laptop_register_person = Person.find_by_id_document("tch004")
    laptop_register_profile = Profile.find_by_internal_tag("laptop_register")
    Perform.destroy(laptop_register_person.performs)
    Perform.create({ :place_id => caacupe_place.id, :person_id => laptop_register_person.id, :profile_id => laptop_register_profile.id }) 

    end
    end
    end

  end

  def self.down
  end
end
