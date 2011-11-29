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

  before_save :set_created_at

  ###
  # Listado
  #
  def self.getColumnas()
    ret = Hash.new
    
    ret[:columnas] = [ 
                      {:name => _("Id"),:key => "shipments.id",:related_attribute => "id", :width => 50},
                      {:name => _("Creation Date"),:key => "shipments.description", 
                        :related_attribute => "getDate()", :width => 120},
                      {:name => _("Arrival Date"),:key => "shipments.created_at",:related_attribute => "getArrivalDate()",
                        :width => 150},
                      {:name => _("Comment"),:key => "shipments.comment",:related_attribute => "getComment()",
                        :width => 350},
                      {:name => _("Number"),:key => "shipments.shipment_number",:related_attribute => "getShipmentNumber()",
                        :width => 350}
                     ]

    ret[:columnas_visibles] = [false, true, true, true]

    ret
  end


  def set_created_at
    self.created_at = Time.now
  end


  def getDate()
    self.created_at.to_s
  end



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
