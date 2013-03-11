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
                                                                         
class Shipment < ActiveRecord::Base
  has_many :laptops

  attr_accessible :arrived_at, :comment, :shipment_number

  FIELDS = [
    {name: _("Id"), column: :id, width: 50, visible: false},
    {name: _("Creation Date"), column: :created_at, width: 120},
    {name: _("Arrival Date"), column: :arrived_at, width: 150},
    {name: _("Comment"), column: :comment, width: 350},
    {name: _("Number"), column: :shipment_number, width: 350},
  ]

  ###
  # Comentario al momento de la creacion del envio
  #
  def getComment()
    self.comment ? self.comment : ""
  end

  ###
  # Name (or handle) of shipment 
  #
  def name
    getComment()
  end

  def getShipmentNumber()
    self.shipment_number ? self.shipment_number : "null"
  end

end
