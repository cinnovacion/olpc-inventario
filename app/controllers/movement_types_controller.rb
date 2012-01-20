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
                                                                        
class MovementTypesController < SearchController

  def search
    do_search(MovementType,nil)
  end

  def search_options
    crearColumnasCriterios(MovementType)
    do_search(MovementType, nil)
  end


  def new
    
    p = nil
    if params[:id]
      p = MovementType.find_by_id(params[:id])
      @output["id"] = p.id
    end
    
    @output["fields"] = []


    h = { "label" => _("Description"), "datatype" => "textfield" }.merge( p ? {"value" => p.description } : {} )
    @output["fields"].push(h)

    options = buildBooleanSelectHash2(p ? p.is_delivery : true)
    h = { "label" => _("Handoff?"), "datatype" => "combobox", :options => options }
    @output["fields"].push(h)

  end
	
  def save
    datos = JSON.parse(params[:payload])
    attribs = Hash.new
    attribs[:description] = datos["fields"][0]
    attribs[:is_delivery] = datos["fields"][1].to_s == "1" ? true : false

    if datos["id"]
      movement_type = MovementType.find_by_id(datos["id"])
      movement_type.update_attributes(attribs)
    else
      MovementType.create!(attribs)
    end

    @output["msg"] = datos["id"] ? _("Changes saved.") : _("Movement type added.")
  end

  def delete
    ids = JSON.parse(params[:payload])
    MovementType.destroy(ids)
    @output["msg"] = _("Elements deleted.")
  end

  def getTypes
    id = MovementType.find_by_internal_tag("entrega_alumno").id
    types = buildSelectHash2(MovementType, id, "description", false, [])
    @output["types"] = types
  end

end
