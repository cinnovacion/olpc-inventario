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
                                                                         
class NodeTypesController < SearchController

  attr_accessor :include_str

  def initialize
    super
    @include_str = [:image]
  end

  def search
    do_search(NodeType, {:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(NodeType)
    do_search(NodeType, {:include => @include_str })
  end

  def new

    if params[:id]
      type = NodeType.find(params[:id])
      @output["id"] = type.id
    else
      type = nil
    end

    @output["fields"] = []

    h = { "label" => "Nombre","datatype" => "textfield" }.merge( type ? {"value" => type.getName } : {} )
    @output["fields"].push(h)

    h = { "label" => "Descripcion", "datatype" => "textarea", "width" => 250, "height" => 50 }.merge( type ? {"value" => type.getDescription } : {} )
    @output["fields"].push(h)

    h = { "label" => "Tag","datatype" => "textfield" }.merge( type ? {"value" => type.getInternalTag } : {} )
    @output["fields"].push(h)

    if type and type.image
      path = "/images/view/#{type.image.id}"
      h = { "label" => "Imagen","datatype" => "image", "value" => path }
      @output["fields"].push(h)
    end

    id = (type and type.image_id) ? type.image.id : -1
    images = buildSelectHash2(Image,id,"getImageName()",true,[])
    h = { "label" => "Imagen", "datatype" => "select", "options" => images, "option" => "images" }
    @output["fields"].push(h)

  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse
    attribs = Hash.new

    attribs[:name] = data_fields.pop
    attribs[:description] = data_fields.pop
    attribs[:internal_tag] = data_fields.pop
    attribs[:image_id] = data_fields.pop

    if datos["id"]
      type = NodeType.find_by_id(datos["id"])
      type.update_attributes(attribs)
    else
      NodeType.create!(attribs)
    end

    @output["msg"] = datos["id"] ? "Cambios guardados." : "Tipo de nodo agregad."
  end

  def delete
    ids = JSON.parse(params[:payload])
    NodeType.destroy(ids)
    @output["msg"] = "Elementos eliminados"
  end


end
