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

require 'fecha'

class LotsController < SearchController
  attr_accessor :include_str

  def initialize
    super 
    @include_str = []
  end

  def search
    do_search(Lot, { :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Lot)
    do_search(Lot, { :include => @include_str })
  end

  def new
    @output["fields"] = []

    if params[:id]
      lot = Lot.find_by_id(params[:id])
      @output["id"] = lot.id
    else
      lot = nil
    end

    h = { "label" => _("Num. of boxes"), "datatype" => "textfield" }.merge( lot ? {"value" => lot.getBoxesNumber } : {} )
    @output["fields"].push(h)

    id = lot ? lot.person_id : -1
    people = buildSelectHashSingle(Person, id, "getFullName()")
    h = { "label" => _("Responsible person"), "datatype" => "select", "options" => people, :option => "personas" }
    @output["fields"].push(h)

    delivered = lot ? lot.delivered : false
    options = buildBooleanSelectHash(delivered)
    h = { "label" => _("Delivered?"), "datatype" => "combobox", "options" => options }
    @output["fields"].push(h)

    fecha = lot ? lot.delivery_date.to_s : Fecha::getFecha()
    h = { "label" => _("Delivery date"),"datatype" => "date", "value" => fecha }
    @output["fields"].push(h)

    ###Dynamic Table for adding sections to the lot.
    options = Array.new

    sections = lot ? lot.section_details.map { |detail| [{ :value => detail.place_id, :text => detail.place.getName }] } : []

    places = buildHierarchyHash(Place, "places", "places.place_id", "name", -1, nil, nil, false)
    h = { "label" => _("Section"), "datatype" => "combobox", "options" => places }
    options.push(h)

    h = {"label" => "", "datatype" => "dyntable", :widths => [320], "options" => options}.merge( lot ? {"data" => sections } : {} )
    @output["fields"].push(h)
   ###END

  end

  def save

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse
    attribs = Hash.new

    attribs[:boxes_number] = data_fields.pop.to_i
    attribs[:person_id] = data_fields.pop.to_i
    attribs[:delivered] = data_fields.pop == "N" ? false : true
    attribs[:delivery_date] = data_fields.pop

    sections = data_fields.pop.map { |data| data["Seccion"].to_i }

    if datos["id"]
      lot = Lot.find_by_id(datos["id"])
      lot.register_update(attribs, sections)
    else
      Lot.register(attribs, sections)
    end

    @output["msg"] = _("Lot created.")
  end

  def delete
    ids = JSON.parse(params[:payload])
    lot = Lot.find_by_id(ids)
    Lot.register_die(lot)
    @output["msg"] = _("Lot deleted.")
  end

end
