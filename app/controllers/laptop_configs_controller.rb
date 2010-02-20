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
                                                                        
class LaptopConfigsController < SearchController

  def search
    do_search(LaptopConfig,nil)
  end

  def search_options
    crearColumnasCriterios(LaptopConfig)
    do_search(LaptopConfig,nil)
  end


  def new
    params[:id]
    p = LaptopConfig.find(params[:id])
    @output["id"] = p.id

    @output["fields"] = []

    if p.key.match(/_id$/)
      label = p.description
      id = p.value ? p.value.to_i : -1
      model = eval(p.key.gsub(/_id/,"").camelize)

      if p.resource_name && !p.resource_name.match(/^ *$/)
        values = buildSelectHash2(model,id,"name",false,["#{model.name.pluralize.downcase}.id = ?", id])
        h = { "label" => label,"datatype" => "combobox","options" => values }
        h["datatype"] = "select"
        h["option"] = p.resource_name 
      else
        values = buildSelectHash2(model,id,"name",false,[])
        h = { "label" => label,"datatype" => "combobox","options" => values }
      end

      @output["fields"].push(h)

    else
      label = p.description
      h = { "label" => label,"datatype" => "textfield" }.merge( p ? {"value" => p.value } : {} )
      @output["fields"].push(h)
    end

  end


  def save
    datos = JSON.parse(params[:payload])
    p = LaptopConfig.find(datos["id"])
    
    value = datos["fields"][0]

    p.value = value
    p.save!

    @output["msg"] = _("Changes saved.")  
  end

end
