class PartMovementTypesController < SearchController

  def search
    do_search(PartMovementType,nil)
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

    h = { "label" => "Nombre", "datatype" => "textfield" }.merge( part_movement_type ? {"value" => part_movement_type.getName } : {} )
    @output["fields"].push(h)

    h = { "label" => "Descripcion", "datatype" => "textfield" }.merge( part_movement_type ? {"value" => part_movement_type.getDescription } : {} )
    @output["fields"].push(h)

    h = { "label" => "Tag interno", "datatype" => "textfield" }.merge( part_movement_type ? {"value" => part_movement_type.getInternalTag } : {} )
    @output["fields"].push(h)

    direction = part_movement_type ? part_movement_type.direction ? true : false : false
    options = [
      { :text => "Entrada", :value => true, :selected =>  direction},
      { :text => "Salida", :value => false, :selected => !direction}
    ]
    h = { "label" => "Direccion", "datatype" => "combobox", :options => options }
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

    @output["msg"] = datos["id"] ? "Cambios guardados" : "Tipo de Movimiento de parte agregado"  
  end

  def delete
    ids = JSON.parse(params[:payload])
    PartMovementType.destroy(ids)
    @output["msg"] = "Elementos eliminados"
  end

end
