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
                                                                         
class ActivationsController < SearchController
  attr_accessor :include_str

  def initialize
    super 
    @include_str = [:laptop,:person_who_activated]
  end

  def search
    do_search(Activation,{ :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Activation)
    do_search(Activation,{ :include => @include_str })
  end


  def new
    
    if params[:id]
      p = Activation.find(params[:id])
      @output["id"] = p.id
    else
      p = nil
    end
    
    @output["fields"] = []


    fecha = Fecha::getFecha()
    h = { "label" => "Fch. Activacion","datatype" => "date", :value => fecha }
    @output["fields"].push(h)

    h = { "label" => "Comentario","datatype" => "textfield" }.merge( p ? {"value" => p.comment } : {} )
    @output["fields"].push(h)

    if p
      opts = buildSelectHash2(Laptop, p.laptop_id,"getSerialNumber", false,["id = ?", p.laptop_id])
    else 
      opts = []
    end
    h = { "label" => "Nro. Serie Laptop","datatype" => "select","options" => opts,"option" => "laptops" } 
    @output["fields"].push(h)

    if p
      people = buildSelectHash2(Person, p.person_activated_id, "getFullName", false, ["id = ?", p.person_activated_id])
    else 
      people = []
    end
    h = { "label" => "Activada por","datatype" => "select","options" => people, "option" => "personas" }
    @output["fields"].push(h)

  end
	
  def save

    datos = JSON.parse(params[:payload])
    attribs = Hash.new

    data_fields = datos["fields"].reverse

    attribs[:date_activated_at] = data_fields.pop
    attribs[:comment] = data_fields.pop
    attribs[:laptop_id] = data_fields.pop
    attribs[:person_activated_id] = data_fields.pop
    
    # Activation.create!(attribs)
    save_object(Activation, datos["id"], attribs)

    @output["msg"] = datos["id"] ? "Cambios guardados" : "Activacion registrada"  
  end

  def delete
    ids = JSON.parse(params[:payload])
    Activation.destroy(ids)
    @output["msg"] = "Elementos eliminados"
  end



end
