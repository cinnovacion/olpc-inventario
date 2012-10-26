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
                                                                    
class PartTypesController < SearchController
  def new

    @output["window_title"] = _("Part types")

    @output["fields"] = []

    if params[:id]
      type = PartType.find(params[:id])
      @output["id"] = type.id
    else
      type = nil
    end

    h = { "label" => _("Name"), "datatype" => "textfield" }.merge( type ? {"value" => type.description() } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Cost"), "datatype" => "textfield" }.merge( type ? {"value" => type.getCost() } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Tag"), "datatype" => "textfield" }.merge( type ? {"value" => type.getInternalTag() } : {} )
    @output["fields"].push(h)

  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:description] = data_fields.pop
    attribs[:cost] = data_fields.pop.to_i
    attribs[:internal_tag] = data_fields.pop

    if datos["id"]
      type = PartType.find_by_id(datos["id"])
      type.update_attributes(attribs)
    else
      PartType.create(attribs)
    end

  end

  def delete
    ids = JSON.parse(params[:payload])
    PartType.destroy(ids)
    @output["msg"] = _("Elements deleted.")
  end

end
