#     Copyright Paraguay Educa 2009
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>
# 
# 

# # #
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #
                                                                         
class Perform < ActiveRecord::Base
  belongs_to :person
  belongs_to :place
  belongs_to :profile

  validates_presence_of :person_id, :message => _("You must specify the person.")
  validates_presence_of :place_id, :message => _("You must specify the place.")
  validates_presence_of :profile_id, :message => _("You must specify the profile.")

  def self.getColumnas()
    ret = Hash.new

    ret[:columnas] = [ 
                      {:name => _("Id"),:key => "performs.id", :related_attribute => "id", :width => 120},
                      {:name => _("Person"),:key => "people.name", :related_attribute => "getPersonName", :width => 250},
                      {:name => _("Location"),:key => "places.name", :related_attribute => "getPlaceName", :width => 250},
                      {:name => _("Profile"),:key => "profile.description", :related_attribute => "getProfileDescription", :width => 250}
                     ]
    ret[:columnas_visibles] = [true, true, true, true]
    ret
  end

  def getPersonaName
    self.person_id ? self.person.getFullName : ""
  end

  def getPlaceName
    self.place_id ? self.place.getName : ""
  end

  def getProfileDescription
    self.profile_id ? self.profile.getDescription : ""
  end

  def self.alreadyExists?(person_id, place_id, profile_id)
    return true if Perform.find_by_person_id_and_place_id_and_profile_id(person_id, place_id, profile_id)
    false
  end

  ###
  # Finds all the people that performs these (profiles_ids) at (place_id, and/or subplaces) 
  #
  def self.peopleFromAs(place_id, subplaces = false, profiles_ids = [])

    places_ids = subplaces ? Place.find_by_id(place_id).getDescendantsIds().push(place_id) : place_id
    cond_v = ["place_id in (?)", places_ids]

    if !profiles_ids.empty?
      cond_v[0] += " and profile_id in (?)"
      cond_v.push(profiles_ids)
    end

    people_ids = Perform.find(:all, :conditions => cond_v).map { |p| p.person_id }

  end

  ###
  #  The only way to avoid huge ambiguity problem between profiles
  #  and data access is to set some rules about the relation between
  #  person's profiles and places.
  def self.check(register, performs)

    places_ids = performs.map { |p| p[0].to_i }
    profiles_ids = performs.map { |p| p[1].to_i }

    # FIRST RULE: Must be exactly 1 perform
    return false if performs.length != 1

    # SECOND RULE: No performing can be created by a lower one.
    highest_profile = Profile.highest(Profile.find_all_by_id(profiles_ids))
    if register.profile.owns(highest_profile)

      #THIRD RULE: a) The highest profile must be at the highest place
      #            b) For one user can only have subtree access
      #            c) All created performed places must be descendants of the registers one
      roots = Place.roots(Place.find_all_by_id(places_ids))
      if roots.length == 1 && register.place.owns(roots.first)

        highest_place = roots.first
        allOk = false
        performs.each { |p|
          # theres has a to be one perform with the highest place and highest profile.
          if p[0].to_i == highest_place.id && p[1].to_i == highest_profile.id

            allOk = true
            break
          end
        }
        #just to make it clear.
        return true if allOk
      end
    end

    #otherwise... nop.
    return false

  end

  protected

  def validate
    errors.add(:person, "This registry already exists") if Perform.alreadyExists?(self.person_id, self.place_id, self.profile_id)
  end

end
