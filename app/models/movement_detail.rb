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

# # #
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #
                                                                         
class MovementDetail < ActiveRecord::Base
  belongs_to :movement
  belongs_to :laptop


  ###
  # Listado
  #
  def self.getColumnas()
    ret = Hash.new
    
    ret[:columnas] = [ 
                      {:name => _("Equipment Type"),:key => "movement_details.description", :related_attribute => "getDescription()", 
                        :width => 120},
                      {:name => _("Serial Nbr."),:key => "movement_details.serial_number",:related_attribute => "getSerialNumber()", 
                        :width => 120},
                      {:name => _("Movement Reason"),:key => "movement_types.description", :related_attribute => "getMovementTypeDesc()", 
                        :width => 120},
                      {:name => _("Delivery Nbr."),:key => "movements.id", :related_attribute => "getMovementNumber()", 
                        :width => 120},                      
                      {:name => _("Delivery date"),:key => "movements.date_moved_at", :related_attribute => "getMovementDate()", 
                        :width => 120}                      
                     ]

    ret[:columnas_visibles] = [true, true, true, true, true]

    ret
  end

  def before_save
    self.description = laptop.getDescription()
    self.serial_number = laptop.getSerialNumber()
  end

  def after_save
    self.checkReturned2 if self.movement.movement_type.is_return?
  end

  def getSerialNumber()
    self.serial_number
  end

  def getMovementTypeDesc()
    self.movement_type.description
  end

  def getMovementNumber()
    self.movement.id
  end
  
  def getDescription()
    self.description
  end

  def getMovementDate()
    self.movement.getMovementDate()
  end

  ##
  # Since movement_type_id column was removed from movement_details
  def movement_type()
    self.movement.movement_type
  end

  ##
  # Checks the lending as returned
  def checkReturned2

    device = self.laptop
    device_class_str = device.class.to_s.downcase

    inc =  [{:movement => :movement_type}]
    cond = ["movement_details.returned = ? and movement_types.internal_tag = ? and movement_details.#{device_class_str}_id = ?", false, "prestamo", device.id]
    movement_detail = MovementDetail.find(:first, :conditions => cond, :include => inc, :order => "movements.id DESC")

    if movement_detail && !movement_detail.returned

      movement_detail.returned = true
      movement_detail.save!
    end

    true
  end

  def getPart
    self.laptop
  end

  ##
  # For spanish purpose
  def getReturned()
    return "Si" if self.returned
    "No"
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:movement => [:movement_type , {:destination_person => {:performs => {:place => :ancestor_dependencies }}}]]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    MovementDetail.with_scope(scope) do
      yield
    end

  end

end
