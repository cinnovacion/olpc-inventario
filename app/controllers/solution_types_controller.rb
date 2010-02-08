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
                                                                      
class SolutionTypesController < SearchController
  def search
    do_search(SolutionType, nil)
  end

  def search_options
    crearColumnasCriterios(SolutionType)
    do_search(SolutionType, nil)
  end

  def new
    @output["window_title"] = "Tipo de soluciones"

    if params[:id]
      solution_type = SolutionType.find_by_id(params[:id])
      @output["id"] = solution_type.id
    else
      solution_type = nil
    end

    @output["fields"] = []

    h = { "label" => "Nombre", "datatype" => "textfield" }.merge( solution_type ? {"value" => solution_type.getName } : {} )
    @output["fields"].push(h)

    h = { "label" => "Descripcion", "datatype" => "textarea" }.merge( solution_type ? {"value" => solution_type.getDescription } : {} )
    @output["fields"].push(h)

    h = { "label" => "Mas info", "datatype" => "textarea" }.merge( solution_type ? {"value" => solution_type.getExtInfo } : {} )
    @output["fields"].push(h)

    h = { "label" => "Tag", "datatype" => "textfield" }.merge( solution_type ? {"value" => solution_type.getInternalTag } : {} )
    @output["fields"].push(h)

    h = { "datatype" => "tab_break", "title" => "Partes Requeridas" }
    @output["fields"].push(h)

    included_part_types = solution_type ? solution_type.part_types : []
    options = PartType.all.map { |part_type| 
      { 
        :label => part_type.getDescription,
        :cb_name => part_type.id,
        :checked => included_part_types.include?(part_type) ? true : false
      }
    }

    h = { "label" => "", "datatype" => "checkbox_selector", :cb_options => options, "max_column" => 1 }
    @output["fields"].push(h)
    
  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:name] = data_fields.pop
    attribs[:description] = data_fields.pop
    attribs[:extended_info] = data_fields.pop
    attribs[:internal_tag] = data_fields.pop
    part_type_ids = data_fields.pop

    if datos["id"]
      solution_type = SolutionType.find_by_id(datos["id"])
      solution_type.register_update(attribs, part_type_ids)
    else
      SolutionType.register(attribs, part_type_ids)
    end

  end

  def delete
    ids = JSON.parse(params[:payload])
    SolutionType.unregister(ids)
  end

end
