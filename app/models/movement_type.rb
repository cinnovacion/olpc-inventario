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
                                                                       
class MovementType < ActiveRecord::Base
  #DEPRECATED: has_many :movement_details
  has_many :movements

  validates_uniqueness_of :internal_tag, :message => N_("The tag must be unique")
  
  ###
  # Listado
  #
  def self.getColumnas()
    ret = Hash.new
    
    ret[:columnas] = [ 
                      {:name => _("Id"), :key => "movement_types.id", :related_attribute => "id", :width => 50},
                      {:name => _("Descritpion"), :key => "movement_types.description", :related_attribute => "description()", :width => 120},
                      {:name => _("Delivery?"), :key => "movement_types.is_delivery", :related_attribute => "getIsDelivery()", :width => 50}                   
                     ]

    ret[:columnas_visibles] = [false, true]

    ret
  end

  def getIsDelivery()
    self.is_delivery
  end

  def is_delivery?
    self.is_delivery && self.internal_tag != "transfer"
  end

  def is_transfer?
    self.internal_tag == "transfer"
  end

  def is_return?
    !self.is_delivery && self.internal_tag != "transfer"
  end

  def is_repair?
    self.internal_tag == "reparacion"
  end

  def self.check(last_movement_type, movement_type)
    return true if not APP_CONFIG["enable_movement_type_checking"]

    if last_movement_type == nil
      return true
    end

    if last_movement_type.is_transfer? && ( movement_type.is_transfer? || movement_type.is_delivery?)
      return true
    end

    if last_movement_type.is_delivery? && (movement_type.is_return?)
      return true
    end

    if last_movement_type.is_return? && ( movement_type.is_transfer? || movement_type.is_delivery? )
      return true
    end

    false
  end

end
