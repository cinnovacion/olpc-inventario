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
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #
                                                                          
class Activation < ActiveRecord::Base
  belongs_to :laptop
  belongs_to :person_who_activated, :class_name => "Person", :foreign_key => :person_activated_id


  validates_presence_of :laptop_id, :message => "Debe proveer el nro. de serie de la laptop activada"

  def before_save
    self.created_at = Time.now
    self.laptop.status_id = Status.find_by_internal_tag("activated").id
    self.laptop.save!
  end


  def self.getColumnas()
    [ 
     {:name => "Id",:key => "activations.id",:related_attribute => "id", :width => 50},
     {:name => "Fch. Act.",:key => "date_activated_at",:related_attribute => "getActivationDate()", :width => 120},
     {:name => "Hora Act.",:key => "time_activated_at",:related_attribute => "getActivationTime()", :width => 120},
     {:name => "Comentario",:key => "comment",:related_attribute => "getComment()", :width => 120},
     {:name => "Nro. Serie Laptop",:key => "laptops.serial_number",:related_attribute => "getSerialNumber()",
       :width => 120},
     {:name => "Activada por",:key => "people.name",:related_attribute => "getActivator()", :width => 120}
    ]
  end


  ###
  # Fecha de activacion
  #
  def getActivationDate()
    self.date_activated_at.to_s
  end

  ###
  # Hora de activacion
  #
  def getActivationTime()
    self.time_activated_at.to_s
  end

  ###
  # Comentario al momento de activar
  #
  def getComment()
    self.comment
  end


  ###
  # Quien activo la laptop..
  #
  def getActivator()
    return self.person_who_activated.getFullName() if self.person_activated_id
    "No one?"
  end

  ###
  # Nro. serie laptop
  #
  def getSerialNumber()
    self.laptop.getSerialNumber()
  end
  

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:laptop => {:owner => {:performs => {:place => :ancestor_dependencies}}}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    Activation.with_scope(scope) do
      yield
    end

  end

end
