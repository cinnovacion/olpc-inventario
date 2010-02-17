class Teach < ActiveRecord::Base
  belongs_to :person
  belongs_to :place

  validates_presence_of :person_id, :message => "Debe especificar la persona."
  validates_presence_of :place_id, :message => "Debe especificar el lugar."

  def self.getColumnas(vista = "")
    ret = Hash.new
    
    ret[:columnas] = [ 
                      {:name => "Id",:key => "profiles.id",:related_attribute => "id", :width => 50},
                      {:name => "Maestra",:key => "people.name",:related_attribute => "getTeacherName()", :width => 140},
                      {:name => "Localidad",:key => "places.description",:related_attribute => "getPlaceDescription()", :width => 140}
                     ]
    ret[:columnas_visibles] = [true,true,true]
    ret
  end

  def getTeacherName()
    self.person_id ? self.person.getFullName() : ""
  end

  def getPlaceDescription()
    self.place_id ? self.place.getDescription() : ""
  end

  def self.register(person_id, places_ids)
    places_ids.each {  |id|
      Teach.create!({:person_id => person_id, :place_id => id}) if !Teach.find_by_person_id_and_place_id(person_id,id)
    }
  end

end