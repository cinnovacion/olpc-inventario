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
                                                                          
class ModelsController < SearchController

  def search
    do_search(Model,nil)
  end

  def search_options
    crearColumnasCriterios(Model)
    do_search(Model,nil)
  end

  def new
    
    if params[:id]
      p = Model.find(params[:id])
      @output["id"] = p.id
    else
      p = nil
    end
    
    @output["fields"] = []

    h = { "label" => "Nombre","datatype" => "textfield" }.merge( p ? {"value" => p.name } : {} )
    @output["fields"].push(h)


    h = { "label" => "Descripcion","datatype" => "textfield" }.merge( p ? {"value" => p.description } : {} )
    @output["fields"].push(h)

  end
	
  def save

    datos = JSON.parse(params[:payload])
    attribs = Hash.new
    attribs[:name] = datos["fields"][0]
    attribs[:description] = datos["fields"][1]

    if datos["id"]
      o = Model.find datos["id"]
      o.update_attributes!(attribs)
    else
      Model.create!(attribs)
    end

    
    @output["msg"] = datos["id"] ? "Cambios guardados" : "Modelo agregado"  
  end

  def delete
    ids = JSON.parse(params[:payload])
    Model.destroy(ids)
    @output["msg"] = "Elementos eliminados"
  end


end
