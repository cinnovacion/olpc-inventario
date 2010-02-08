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
                                                                         
class Box < ActiveRecord::Base

  belongs_to :place
  belongs_to :shipment
  

  has_many :laptops
  has_many :chargers
  has_many :batteries

  validates_presence_of :shipment_id, :message => "Debe proveer el cargamento asociado a la caja"
  validates_presence_of :place_id, :message => "Debe proveer la localidad asociada a la caja"
  validates_presence_of :serial_number, :message => "Debe proveer el nro. de serie"
  validates_uniqueness_of :serial_number, :message => "El nro. de serie de la caja no puede ser repetido"


  def self.getColumnas()
    ret = Hash.new
    
    ret[:columnas] = 
      [ 
       {:name => "Id",:key => "boxes.id",:related_attribute => "id", :width => 50},
       {:name => "Nro. Serie",:key => "boxes.serial_number",:related_attribute => "serial_number", :width => 180},
       {:name => "Localidad",:key => "places.name",:related_attribute => "getPlaceName()", :width => 180},
       {:name => "Cargamento",:key => "shipments.comment",:related_attribute => "getShipmentName()", :width => 180},
       {:name => "# Laptops",:key => "boxes.id",:related_attribute => "getNumLaptops()", :width => 120},
       {:name => "# Cargadores",:key => "boxes.id",:related_attribute => "getNumBatteries()", :width => 120},
       {:name => "# Baterias",:key => "boxes.id",:related_attribute => "getNumChargers()", :width => 120},

      ]

    ret[:columnas_visibles] = [false, true, true ]

    ret
  end


  def getShipmentName()
    self.shipment.getComment()
  end
 
  def getPlaceName()
    self.place.getName()
  end

  def getNumLaptops
    self.laptops.length
  end

  def getNumBatteries
    self.batteries.length
  end

  def getNumChargers
    self.chargers.length
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:place => :ancestor_dependencies]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    Box.with_scope(scope) do
      yield
    end

  end

end
