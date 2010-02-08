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
                                                                       
class BoxMovementsController < SearchController
  attr_accessor :include_str

  def initialize
    super 
    @include_str = [:src_place,:src_person,:dst_place,:dst_person,:authorizer]
  end

  def search
    do_search(BoxMovement,{ :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(BoxMovement)
    do_search(BoxMovement, { :include => @include_str })
  end


  def new
    @output["fields"] = []

    p = nil
    if params[:id]
      p = BoxMovement.find params[:id]
      @output["id"] = p.id
    end

    fecha = p ? p.getDate() : Fecha::getFecha()
    h = { "label" => "Fch. Mov.","datatype" => "date",  :value => fecha  }
    @output["fields"].push(h)

    id = p ? p.src_place_id : -1
    places = buildHierarchyHash(Place, "places", "places.place_id", "name", id, nil, nil, false)
    h = { "label" => "Localidad origen","datatype" => "combobox","options" => places }
    @output["fields"].push(h)

    opts = []
    if p 
      opts = buildSelectHash2(Person, p.src_person_id, "getFullName()",false,["id = ?", p.src_person_id])
    end
    h = { "label" => "En manos de","datatype" => "select","options" => opts, "option" => "personas" }
    @output["fields"].push(h)

    id = p ? p.dst_place_id : -1
    places = buildHierarchyHash(Place, "places", "places.place_id", "name", id, nil, nil, false)
    h = { "label" => "Localidad destino","datatype" => "combobox","options" => places }
    @output["fields"].push(h)

    opts = []
    if p 
      opts = buildSelectHash2(Person, p.dst_person_id, "getFullName()",false,["id = ?", p.dst_person_id])
    end
    h = { "label" => "A manos de","datatype" => "select","options" => opts, "option" => "personas" }
    @output["fields"].push(h)

    opts = []
    if p 
      opts = buildSelectHash2(Person, p.authorized_person_id, "getFullName()",false,["id = ?", p.authorized_person_id])
    end
    h = { "label" => "Autorizado por","datatype" => "select","options" => opts, "option" => "personas" }
    @output["fields"].push(h)


    opts = []
    if p
      p.box_movement_details.find(:all, :include => [:box]).each { |d|
        opts << [d.box.serial_number]
      }
    end

    h = { :label => "Cajas",
          :hashed_data => ["serial_number"],
          :datatype => "table",
          :rows_num => 20,
          :height => 100,
          :col_titles => ["Nro. Serie"],
          :widths => [150],
          :width => 390,
          :editables => [true],
          :options => opts,
          :option => "boxes",
          :cols_mapping => [1],
          :columnas_visibles => [ true]
    }
    @output["fields"].push(h)    
    @output["window_width"] = 600
    @output["window_height"] = 320


  end

  def save
    datos = JSON.parse(params[:payload])

    attribs = Hash.new

    data_fields = datos["fields"].reverse
      
    attribs[:date_moved_at] = data_fields.pop
    attribs[:src_place_id] = data_fields.pop
    attribs[:src_person_id] = data_fields.pop
    attribs[:dst_place_id] = data_fields.pop
    attribs[:dst_person_id] = data_fields.pop
    attribs[:authorized_person_id] = data_fields.pop

    tabla = data_fields.pop
    boxIds = tabla.map { |f|  Box.find_by_serial_number(f["serial_number"]).id }

    
    BoxMovement.crear(attribs, boxIds)

    @output["msg"] = "Movimiento de cajas registrado"
  end

  
  

end
