#     Copyright Paraguay Educa 2010
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
# Author: Martin Abente - mabente@paraguayeduca.org
#

class PartMovementTypesController < SearchController

  def search
    do_search(PartMovementType, nil)
  end

  def search_options
    crearColumnasCriterios(PartMovementType)
    do_search(PartMovementType, nil)
  end

  def new
    
    part_movement_type = nil
    if params[:id]
      part_movement_type = PartMovementType.find_by_id(params[:id])
      @output["id"] = part_movement_type.id
    end
    
    @output["fields"] = []

    h = { "label" => _("Name"), "datatype" => "textfield" }.merge( part_movement_type ? {"value" => part_movement_type.getName } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Description"), "datatype" => "textfield" }.merge( part_movement_type ? {"value" => part_movement_type.getDescription } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Internal tag"), "datatype" => "textfield" }.merge( part_movement_type ? {"value" => part_movement_type.getInternalTag } : {} )
    @output["fields"].push(h)

    direction = part_movement_type ? part_movement_type.direction ? true : false : false
    options = [
      { :text => _("Incoming"), :value => true, :selected =>  direction},
      { :text => _("Outgoing"), :value => false, :selected => !direction}
    ]
    h = { "label" => _("Direction"), "datatype" => "combobox", :options => options }
    @output["fields"].push(h)
  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:name] = data_fields.pop
    attribs[:description] = data_fields.pop
    attribs[:internal_tag] = data_fields.pop
    attribs[:direction] = data_fields.pop == "true" ? true : false

    if datos["id"]
      part_movement_type = PartMovementType.find_by_id(datos["id"])
      part_movement_type.update_attributes(attribs)
    else
      PartMovementType.create!(attribs)
    end

    @output["msg"] = datos["id"] ? _("Changes saved") : "Part movement type added."  
  end

  def delete
    ids = JSON.parse(params[:payload])
    PartMovementType.destroy(ids)
    @output["msg"] = "Elements deleted."
  end

end
