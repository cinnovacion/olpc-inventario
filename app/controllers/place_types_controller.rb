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
                                                                          
class PlaceTypesController < SearchController
  def search
    do_search(PlaceType, nil)
  end

  def search_options
    crearColumnasCriterios(PlaceType)
    do_search(PlaceType, nil)
  end

  def new
    @output["fields"] = []

    if params[:id]
      type = PlaceType.find_by_id(params[:id])
      @output["id"] = type.id
    else
      type = nil
    end

    h = { "label" => "Nombre","datatype" => "textfield" }.merge( type ? {"value" => type.getName } : {} )
    @output["fields"].push(h)

    h = { "label" => "Internal Tag","datatype" => "textfield" }.merge( type ? {"value" => type.getInternalTag } : {} )
    @output["fields"].push(h)

  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:name] = data_fields.pop
    attribs[:internal_tag] = data_fields.pop

   if datos["id"]
     type = PlaceType.find_by_id(datos["id"])
     type.update_attributes(attribs)
   else
     PlaceType.create!(attribs)
   end

    @output["msg"] = datos["id"] ? "Cambios guardados" : "Tipo de lugar agregado"
  end

  def delete
    ids = JSON.parse(params[:payload])
    PlaceType.destroy(ids)
    @output["msg"] = "Elementos eliminados"
  end

end
