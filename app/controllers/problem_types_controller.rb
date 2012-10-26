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
                                                                       
class ProblemTypesController < SearchController
  def new
    @output["window_title"] = _("Configuration of problem types")

    if params[:id]
      problem_type = ProblemType.find_by_id(params[:id])
      @output["id"] = problem_type.id
    else
      problem_type = nil
    end

    @output["fields"] = []

    h = { "label" => _("Name"), "datatype" => "textfield" }.merge( problem_type ? {"value" => problem_type.getName } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Description"), "datatype" => "textarea" }.merge( problem_type ? {"value" => problem_type.description } : {} )
    @output["fields"].push(h)

    h = { "label" => _("More info"), "datatype" => "textarea" }.merge( problem_type ? {"value" => problem_type.getExtInfo } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Internal tag"), "datatype" => "textfield" }.merge( problem_type ? {"value" => problem_type.getInternalTag } : {} )
    @output["fields"].push(h)

    yesSelected = problem_type ? problem_type.is_hardware : false
    options = buildBooleanSelectHash(yesSelected)
    h = { "label" => _("Hardware?"), "datatype" => "combobox", "options" => options}
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
    attribs[:is_hardware] = data_fields.pop == "N" ? false : true

    if datos["id"]
      problem_type = ProblemType.find_by_id(datos["id"])
      problem_type.update_attributes(attribs)
    else
      ProblemType.create(attribs)
    end

    @output["msg"] = datos["id"] ? _("Changes saved.") : _("Problem type created.")  
  end

  def delete
    ids = JSON.parse(params[:payload])
    ProblemType.destroy(ids)
    @output["msg"] = _("Elements deleted.")
  end

end
