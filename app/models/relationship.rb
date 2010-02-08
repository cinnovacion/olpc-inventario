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
                                                                         
class Relationship < ActiveRecord::Base
  belongs_to :person
  belongs_to :to_person, :class_name => "Person", :foreign_key => :to_person_id
  belongs_to :profile

  validates_presence_of :person_id, :message => "Debe especificar la persona."
  validates_presence_of :to_person_id, :message => "Debe especificar la persona a la cual se relaciona."
  validates_presence_of :profile_id, :message => "Debe especificar el rol."

  def self.getColumnas()
    ret = Hash.new

    ret[:columnas] = [
                      {:name => "Id",:key => "relatioships.id", :related_attribute => "id", :width => 120},
                      {:name => "Persona",:key => "people.name", :related_attribute => "getPersonName", :width => 250},
                      {:name => "Relacionada a",:key => "people.name", :related_attribute => "getToPersonName", :width => 250},
                      {:name => "Rol",:key => "profiles.description", :related_attribute => "getProfileDescription", :width => 250}
                     ]
    ret[:columnas_visibles] = [true, true, true, true]
    ret
  end

  def getPersonName
    self.person_id ? self.person.getFullName : ""
  end

  def getToPersonName
    self.to_person_id ? self.to_person.getFullName : ""
  end

  def getProfileDescription
    self.profile_id ? self.profile.getDescription : ""
  end

  def self.alreadyExists?(person_id,to_person_id,profile_id)
    return true if Relationship.find_by_person_id_and_to_person_id_and_profile_id(person_id, to_person_id, profile_id)
    false
  end

  protected

  def validate
    errors.add(:person, "Esta relacion ya existe.") if Relationship.alreadyExists?(self.person_id, self.to_person_id, self.profile_id)

    errors.add(:person, "No se puede relacionar consigo mismo.") if self.person_id == self.to_person_id

  end

end
