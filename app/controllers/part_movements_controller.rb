class PartMovementsController < SearchController

  def initialize
    super 
    @include_str = [:part_movement_type, :part_type, :person, :place]
  end

  def search
    do_search(PartMovement,{:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(PartMovement)
    do_search(PartMovement,{:include => @include_str })
  end

  def new 

    part_movement = nil
    if params[:id]
      part_movement = PartMovement.find_by_id(params[:id])
      @output["id"] = part_movement.id
    end

    @output["window_title"] = "Nuevo movimiento de partes"
    @output["fields"] = []

    id = part_movement ? part_movement.part_movement_type.id : nil
    part_movement_types = buildSelectHash2(PartMovementType, id, "getName", false, [])
    h = { "label" => "Tipo de movimiento", "datatype" => "combobox", "options" => part_movement_types }
    @output["fields"].push(h)

    id = part_movement ? part_movement.part_type.id : nil
    part_types = buildSelectHash2(PartType, id, "getDescription", false, [])
    h = { "label" => "Tipo de parte", "datatype" => "combobox", "options" => part_types }
    @output["fields"].push(h)

    h = { "label" => "Cantidad", "datatype" => "textfield" }.merge( part_movement ? {"value" => part_movement.getAmount } : {} )
    @output["fields"].push(h)

    #options = (part_movement && part_movement.person) ? [{ :text => part_movement.person.getFullName, :value => part_movement.person.id, :selected => true}] : []
    #h = { "label" => "Responsable (CI)", "datatype" => "select", "options" => options, "option" => "personas" }
    #@output["fields"].push(h)

    h = { "label" => "Localidad", "datatype" => "hierarchy_on_demand", "options" => { "width" => 360, "height" => 50 }}
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
    @output["msg"] = "Elementos eliminados"
  end

  def new_transfer

    @output["window_title"] = "Transferencia de partes"
    @output["fields"] = []

    part_types = buildSelectHash2(PartType, -1, "getDescription", false, [])
    h = { "label" => "Tipo de parte", "datatype" => "combobox", "options" => part_types }
    @output["fields"].push(h)

    h = { "label" => "Cantidad", "datatype" => "textfield" }
    @output["fields"].push(h)

    h = { "label" => "Localidad Origen", "datatype" => "hierarchy_on_demand", "options" => { "width" => 360, "height" => 50 }}
    @output["fields"].push(h)

    h = { "label" => "Localidad Destino", "datatype" => "hierarchy_on_demand", "options" => { "width" => 360, "height" => 50 }}
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
    @output["msg"] = "La transferencia se ha realizado correctamente"
  end

end
