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

class PartMovementsController < SearchController
  def initialize
    includes = [:part_movement_type, :part_type, :person, :place]
    super(:includes => includes)
  end

  def new 

    part_movement = nil
    if params[:id]
      part_movement = PartMovement.find_by_id(params[:id])
      @output["id"] = part_movement.id
    end

    @output["window_title"] = _("Add a new movement of parts.")
    @output["fields"] = []

    id = part_movement ? part_movement.part_movement_type.id : nil
    part_movement_types = buildSelectHash2(PartMovementType, id, "name", false, [])
    h = { "label" => _("Movement type"), "datatype" => "combobox", "options" => part_movement_types }
    @output["fields"].push(h)

    id = part_movement ? part_movement.part_type.id : nil
    part_types = buildSelectHash2(PartType, id, "description", false, [])
    h = { "label" => _("Part type"), "datatype" => "combobox", "options" => part_types }
    @output["fields"].push(h)

    h = { "label" => _("Quantity"), "datatype" => "textfield" }.merge( part_movement ? {"value" => part_movement.getAmount } : {} )
    @output["fields"].push(h)

    #options = (part_movement && part_movement.person) ? [{ :text => part_movement.person.getFullName, :value => part_movement.person.id, :selected => true}] : []
    #h = { "label" => "Responsable (CI)", "datatype" => "select", "options" => options, "option" => "people" }
    #@output["fields"].push(h)

    h = { "label" => _("Place"), "datatype" => "hierarchy_on_demand", "options" => { "width" => 360, "height" => 50 }}
    h.merge!( part_movement && part_movement.place ? {"dataHash" => part_movement.place.getElementsHash } : {} )
    @output["fields"].push(h)

  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:part_movement_type_id] = data_fields.pop.to_i
    attribs[:part_type_id] = data_fields.pop.to_i
    attribs[:amount] = data_fields.pop.to_i
    #attribs[:person_id] = data_fields.pop.to_i
    attribs[:place_id] = data_fields.pop.to_i
    attribs[:person_id] = current_user.person.id

    if datos["id"]
      part_movement = PartMovement.find_by_id(datos["id"])
      part_movement.update_attributes(attribs)
    else
      PartMovement.create!(attribs)
    end
  end

  def delete
    part_movement_ids = JSON.parse(params[:payload])
    PartMovement.delete(part_movement_ids)
    @output["msg"] = _("Elements deleted.")
  end

  def new_transfer

    @output["window_title"] = _("Transfer parts.")
    @output["fields"] = []

    part_types = buildSelectHash2(PartType, -1, "description", false, [])
    h = { "label" => _("Part type"), "datatype" => "combobox", "options" => part_types }
    @output["fields"].push(h)

    h = { "label" => _("Quantity"), "datatype" => "textfield" }
    @output["fields"].push(h)

    h = { "label" => _("Source place"), "datatype" => "hierarchy_on_demand", "options" => { "width" => 360, "height" => 50 }}
    @output["fields"].push(h)

    h = { "label" => _("Destination place"), "datatype" => "hierarchy_on_demand", "options" => { "width" => 360, "height" => 50 }}
    @output["fields"].push(h)
  end

  def save_transfer

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = {}
    attribs[:person_id] = current_user.person.id
    attribs[:part_type_id] = data_fields.pop.to_i
    attribs[:amount] = data_fields.pop.to_i

    from_place_id = data_fields.pop.to_i
    to_place_id = data_fields.pop.to_i

    PartMovement.registerTransfer(attribs, from_place_id, to_place_id)
    @output["msg"] = _("Transfer saved.")
  end

end
