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
                                                                         
class ChargersController < SearchController
  attr_accessor :include_str

  def initialize
    super 
    @include_str = [:status,:shipment]
  end

  def search
    do_search(Charger,{ :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Charger)
    do_search(Charger, { :include => @include_str })
  end

  def new
    @output["fields"] = []

    if params[:ids] 
      ids = JSON.parse(params[:ids])
      new_batch_edit(ids)
    else
      new_single_edit()
    end

  end
	
  def save

    datos = JSON.parse(params[:payload])

    if datos["ids"]
      modify_batch(datos)
    else
      attribs = Hash.new

      data_fields = datos["fields"].reverse

      attribs[:serial_number] = data_fields.pop
      attribs[:shipment_arrival_id] = data_fields.pop
      attribs[:owner_id] = data_fields.pop
      attribs[:box_serial_number] = data_fields.pop
      attribs[:status_id] = data_fields.pop
      
      if datos["id"]
        o = Charger.find datos["id"]
        o.update_attributes!(attribs)
      else
        Charger.create!(attribs)
      end
    end
      
    @output["msg"] = datos["id"] || datos["ids"]  ? "Cambios guardados" : "Cargador agregada"  
  end

  def delete
    ids = JSON.parse(params[:payload])
    Charger.destroy(ids)
    @output["msg"] = "Elementos eliminados"
  end


  private 

  def new_single_edit()
    
    if params[:id]
      p = Charger.find(params[:id])
      @output["id"] = p.id
    else
      p = nil
    end
    
    @output["fields"] = []

    h = { "label" => "Nro. Serial","datatype" => "textfield" }.merge( p ? {"value" => p.serial_number } : {} )
    @output["fields"].push(h)

    id =  p ? p.shipment_arrival_id : -1
    shipments = buildSelectHash2(Shipment,id,"comment",false,[])
    h = { "label" => "Cargamento","datatype" => "combobox","options" => shipments }
    @output["fields"].push(h)

    id = p ? p.owner_id : -1
    #people = buildSelectHash2(Person,id,"getFullName()",false,[])
    people = buildSelectHashSingle(Person,id,"getFullName()")
    h = { "label" => "En manos de","datatype" => "select","options" => people, :option => "personas" }
    @output["fields"].push(h)

    h = { "label" => "Id Caja","datatype" => "textfield" }.merge( p ? {"value" => p.box_serial_number } : {} )
    @output["fields"].push(h)

    id = p && p.status ? p.status_id : Status.find_by_internal_tag("deactivated").id
    statuses = buildSelectHash2(Status,id,"getDescription()",false,[])
    h = { "label" => "Estado","datatype" => "combobox","options" => statuses }
    @output["fields"].push(h)

  end


  def new_batch_edit(ids)
    p = Charger.find(ids[0])

    @output["ids"] = ids

    # User must check fields that where updated 
    @output["needs_update"] = true

    id =  p ? p.shipment_arrival_id : -1
    shipments = buildSelectHash2(Shipment,id,"comment",false,[])
    h = { "label" => "Cargamento","datatype" => "combobox","options" => shipments }
    @output["fields"].push(h)

    id = p ? p.owner_id : -1
    people = buildSelectHash2(Person,id,"getFullName()",false,[])
    h = { "label" => "En manos de","datatype" => "combobox","options" => people }
    @output["fields"].push(h)

    h = { "label" => "Id Caja","datatype" => "textfield" }.merge( p ? {"value" => p.box_serial_number } : {} )
    @output["fields"].push(h)

    id = p && p.status ? p.status_id : Status.find_by_internal_tag("deactivated").id
    statuses = buildSelectHash2(Status,id,"getDescription()",false,[])
    h = { "label" => "Estado","datatype" => "combobox","options" => statuses }
    @output["fields"].push(h)

  end


  def modify_batch(datos)
    data_fields = datos["fields"].reverse

    attribs = Hash.new

    h = data_fields.pop
    if h["updated"] ==  true
      attribs[:shipment_arrival_id] = getAbmFormValue(h)
    end

    h = data_fields.pop
    if h["updated"] ==  true
      attribs[:owner_id] = getAbmFormValue(h)
    end

    h = data_fields.pop
    if h["updated"] ==  true
      attribs[:box_serial_number] = getAbmFormValue(h)
    end

    h = data_fields.pop
    if h["updated"] ==  true
      attribs[:status_id] = getAbmFormValue(h)
    end

    objs = Charger.find(datos["ids"])
    Charger.transaction do
      objs.each { |o|
        o.update_attributes!(attribs)
      }
    end


  end



end
