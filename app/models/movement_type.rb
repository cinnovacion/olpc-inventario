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
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 

class MovementType < ActiveRecord::Base
  has_many :movements

  attr_accessible :description, :internal_tag, :is_delivery

  validates_uniqueness_of :internal_tag, :message => N_("The tag must be unique")
  
  def self.getColumnas
    {
      columnas: [
        {name: _("Id"), key: "movement_types.id", related_attribute: "id", width: 50},
        {name: _("Descritpion"), key: "movement_types.description", related_attribute: "description", width: 120},
        {name: _("Delivery?"), key: "movement_types.is_delivery", related_attribute: "is_delivery", width: 50}                   
      ],
      columnas_visibles: [false, true]
    }
  end

  def to_s
    self.description
  end

  def is_delivery?
    is_delivery && internal_tag != "transfer"
  end

  def is_transfer?
    internal_tag == "transfer"
  end

  def is_return?
    !is_delivery && internal_tag != "transfer"
  end

  def is_repair?
    internal_tag == "reparacion"
  end

  def is_loan?
    internal_tag == "prestamo"
  end

  def self.check(last_movement_type, movement_type)
    return true if not APP_CONFIG["enable_movement_type_checking"]

    if last_movement_type.nil?
      return true
    end

    if last_movement_type.is_transfer? && (movement_type.is_transfer? || movement_type.is_delivery?)
      return true
    end

    if last_movement_type.is_delivery? && (movement_type.is_return?)
      return true
    end

    if last_movement_type.is_return? && (movement_type.is_transfer? || movement_type.is_delivery?)
      return true
    end

    false
  end
end
