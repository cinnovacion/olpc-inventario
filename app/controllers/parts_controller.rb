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
                                                                        
class PartsController < SearchController
  attr_accessor :include_str

  def initialize
    super
    @include_str = [:status, :part_type, :laptop, :battery, :charger]
  end

  def search
    do_search(Part,{:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Part)
    do_search(Part,{:include => @include_str })
  end

  def new
    @output["window_title"] = "Partes"

    if params[:id]
      part = Part.find_by_id(params[:id])
      @output[:id] = part.id
    else
      part = nil
    end

    @output["fields"] = []

    id = part ? part.part_type_id : -1
    part_types = buildSelectHash2(PartType, id, "description", false, [])
    h = { "label" => "Tipo", "datatype" => "combobox", "options" => part_types }
    @output["fields"].push(h)

    id = part && part.laptop_id ? part.laptop_id : -1
    laptop = buildSelectHash2(Laptop, id, "getSerialNumber", false, ["laptops.id = ?",id])
    h = { "label" => "Laptop","datatype" => "select","options" => laptop, "option" => "laptops" }
    @output["fields"].push(h)

    id = part && part.battery_id ? part.battery_id : -1
    battery = buildSelectHash2(Battery, id, "getSerialNumber", false, ["batteries.id = ?",id])
    h = { "label" => "Bateria", "datatype" => "select", "options" => battery, "option" => "baterias" }
    @output["fields"].push(h)

    id = part && part.charger_id ? part.charger_id : -1
    charger = buildSelectHash2(Charger, id, "getSerialNumber", false, ["chargers.id = ?",id])
    h = { "label" => "Cargador", "datatype" => "select", "options" => charger, "option" => "cargadores" }
    @output["fields"].push(h)

    id = part ? part.status_id : -1
    condition = ["statuses.internal_tag in (?)",["available","used","broken","ripped"]]
    statuses = buildSelectHash2(Status, id, "description", false, condition)
    h = { "label" => "Estado","datatype" => "combobox","options" => statuses }
    @output["fields"].push(h)

  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:part_type_id] = data_fields.pop.to_i
    laptop_id = data_fields.pop.to_i
    attribs[:laptop_id] = laptop_id != -1 ? laptop_id : nil
    battery_id = data_fields.pop.to_i
    attribs[:battery_id] = battery_id != -1 ? battery_id : nil
    charger_id = data_fields.pop.to_i
    attribs[:charger_id] = charger_id != -1 ? charger_id : nil
    attribs[:status_id] = data_fields.pop.to_i

    if verifyAttribs(attribs)
      attribs[:owner_id] = Part.getAttribsOwner(attribs)
      if datos["id"]
        part = Part.find_by_id(datos["id"])
        part.update_attributes(attribs)
      else
        Part.register(attribs)
      end
    end

  end

  def delete
    ids = JSON.parse(params[:payload])
    Part.destroy(ids)
  end

  def new_spare_parts

    @output["fields"] = []

    h = { "label" => "Serial", "datatype" => "textfield" }
    @output["fields"].push(h)

    conditions = ["part_types.internal_tag in (?)",["laptop"]]
    part_types = buildSelectHash2(PartType, -1, "description", false, conditions)
    h = { "label" => "Dispositivo", "datatype" => "combobox", "options" => part_types }
    @output["fields"].push(h)

    conditions = ["part_types.internal_tag not in (?)",["laptop","battery","charger"]]
    part_types = buildSelectHash2(PartType, -1, "description", false, conditions)
    h = { "label" => "Sub Parte", "datatype" => "combobox", "options" => part_types }
    @output["fields"].push(h)

    h = { "label" => "Cantidad", "datatype" => "textfield" }
    @output["fields"].push(h)
  end

  def save_spare_parts

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    impure_attribs = Hash.new
    impure_attribs[:ghost_device_serial] = data_fields.pop
    impure_attribs[:device_part_type_id] = data_fields.pop.to_i
    impure_attribs[:part_type_id] = data_fields.pop.to_i
    impure_attribs[:amount] = data_fields.pop.to_i

    Part.register_spare_parts(impure_attribs, current_user.person)

  end

  private
  def verifyAttribs(attribs)

    laptop_id = attribs[:laptop_id]
    battery_id = attribs[:battery_id]
    charger_id = attribs[:charger_id]
    part_type_id = attribs[:part_type_id]

    check_collection = [laptop_id, battery_id, charger_id]
    check_collection.delete(nil)
    if check_collection.length != 1
      raise "Debe especificar EL dispositivo del cual proviene esta parte."
    end

    true
  end

end
