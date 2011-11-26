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
                                                                      
class StatusChange < ActiveRecord::Base
  belongs_to :previous_state, :class_name => "Status", :foreign_key => :previous_state_id
  belongs_to :new_state, :class_name => "Status", :foreign_key => :new_state_id
  belongs_to :laptop
  belongs_to :battery
  belongs_to :charger

  #DEBUG: validates_presence_of :previous_state_id, :message => "Debe proveer el estado anterior."
  validates_presence_of :new_state_id, :message => N_("You must provide the new state.")

  def self.getColumnas()
    ret = Hash.new
    ret[:columnas] = [
                      {
                        :name => _("Id"),
                        :key => "status_changes.id",
                        :related_attribute => "id",
                        :width => 50
                      },
                      {
                        :name => _("Previous state"),
                        :key => "statuses.description",
                        :related_attribute => "getPreviousState()",
                        :width => 240
                      },
                      {
                        :name => _("New State"),
                        :key => "statuses.description",
                        :related_attribute => "getNewState()",
                        :width => 240
                      },
                      {
                        :name => _("Laptop"),
                        :key => "laptops.serial_number",
                        :related_attribute => "getSerial()",
                        :width => 120
                      },
                      {
                        :name => _("Battery"),
                        :key => "batteries.serial_number",
                        :related_attribute => "getSerial()",
                        :width => 120
                      },
                      {
                        :name => _("Charger"),
                        :key => "chargers.serial_number",
                        :related_attribute => "getSerial()",
                        :width => 120
                      },
                      {
                        :name => _("Creation Date"),
                        :key => "date_created_at",
                        :related_attribute => "getDate()",
                        :width => 120
                      },
                      {
                        :name => _("Creation Time"),
                        :key => "time_created_at",
                        :related_attribute => "getTime()",
                        :width => 120
                      }
                     ]

    ret[:columnas_visibles] = [false,true,true,true,true,true,true,true]
    ret
  end
  
  ##
  # Previous state
  #
  def getPreviousState()
    return self.previous_state.getDescription() if self.previous_state_id
    "null"
  end

  ##
  # New state
  #
  def getNewState()
    return self.new_state.getDescription() if self.new_state_id
    "null"
  end

  ##
  # Laptop's serial number
  #
  def getLaptopSerial()
    self.laptop.getSerialNumber()
  end

  ##
  # Battery's serial number
  #
  def getBatterySerial()
    self.battery.getSerialNumber()
  end

  ##
  # Charger's serial number
  #
  def getChargerSerial()
    self.charger.getSerialNumber()
  end

  ##
  # Creation date
  #
  def getDate()
    self.date_created_at.to_s
  end

  ##
  # Creation time
  #
  def getTime()
    self.time_created_at.to_s
  end

  ##
  # what type of part are we talking about?
  #
  def getPart()
    return "laptop" if self.laptop_id
    return "battery" if self.battery_id
    return "charger" if self.charger_id
    "error"
  end

  ##
  # Serial number of the part.
  #
  def getSerial()
    return getLaptopSerial() if self.laptop_id
    return getBatterySerial() if self.battery_id
    return getChargerSerial() if self.charger_id
    "error"
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)
    scope = includes(:laptop => {:owner => {:performs => {:place => :ancestor_dependencies}}})
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    StatusChange.with_scope(scope) do
      yield
    end
  end

end
