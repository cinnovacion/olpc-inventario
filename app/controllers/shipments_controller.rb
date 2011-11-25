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

require 'lib/fecha'

class ShipmentsController < SearchController

  def search
    do_search(Shipment,nil)
  end

  def search_options
    crearColumnasCriterios(Shipment)
    do_search(Shipment, nil)
  end

  def new
    if params[:id]
      p = Shipment.find(params[:id])
      @output["id"] = p.id
    else
      p = nil
    end
  
    @output["fields"] = []

    h = { "label" => _("Comment"), "datatype" => "textfield" }.merge( p ? {"value" => p.getComment } : {} )
    @output["fields"].push(h)

    fecha = p ? p.arrived_at.to_s : Fecha::getFecha()
    h = { "label" => _("Arrival date"), "datatype" => "date", "value" => fecha }
    @output["fields"].push(h)

    h = { "label" => _("Number"), "datatype" => "textfield" }.merge( p ? {"value" => p.getShipmentNumber } : {} )
    @output["fields"].push(h)
  end
	
  def save
    datos = JSON.parse(params[:payload])
    attribs = Hash.new
    attribs[:comment] = datos["fields"][0]
    attribs[:arrived_at] = datos["fields"][1]
    attribs[:shipment_number] = datos["fields"][2]

    
    if datos["id"]
      o = Shipment.find_by_id(datos["id"])
      o.update_attributes!(attribs)
    else
      Shipment.create!(attribs)
    end

    @output["msg"] = datos["id"] ? _("Changes saved.") : _("Shipment added.")  
  end

  def delete
    ids = JSON.parse(params[:payload])
    Shipment.destroy(ids)
    @output["msg"] = _("Elements deleted.")
  end

end
