class AddSchoolInfo < ActiveRecord::Migration
  def self.up
    placesObj = PlaceType.find_by_internal_tag("school").places
    
    Place.transaction do 
      placesObj.each { |p|
        if p.school_info == nil 
          sObj = SchoolInfo.new
          school_number = p.name.to_i
          sObj.server_hostname = "schoolserver.escuela#{school_number}.caacupe.paraguayeduca.org"
          sObj.save!
          p.school_info = sObj
          p.save!
        end
      }
    end
 
  end

  def self.down

  end
end
