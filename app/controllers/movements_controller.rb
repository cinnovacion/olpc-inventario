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

# # #
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #
                                                                          
class MovementsController < SearchController
  skip_filter :rpc_block, :only => [ :show, :create, :update, :destroy, :index ]

  def index
     all = Movement.find(:all)
     render :xml => all.to_xml
  end
 
  def show
    mov = Movement.find_by_id(params["id"])
    render :xml => mov.to_xml
  end

  def create
    Movement.register(params[:movement])
    mov = Movement.find(params[:movement])
    render :xml => mov.to_xml, :status => :created
  end

  def update
    mov = Movement.find_by_id(params["id"])
    mov.update_attributes(params[:movement])
    render :xml => mov.to_xml, :status => :ok
  end

  def destroy
    Movement.destroy(params["id"])
    render :status => :ok
  end

  attr_accessor :include_str

  def initialize
    super 
    @include_str = [:source_person, :destination_person, :movement_type]
  end

  def search
    do_search(Movement,{:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Movement)
    do_search(Movement,{:include => @include_str })
  end

  def new 

    @output["window_title"] = "Entregar laptops"

    @output["fields"] = []

    @output["verify_before_save"] = true
    @output["verify_save_url"] = "/movements/verify_save"

    ### TEST
    places = buildHierarchyHash(Place, "places", "places.place_id", "name", -1, nil, nil, false)
    h = { "label" => "Localidad","datatype" => "combobox","options" => places, "vista_widget" => 2, "vista" => "any" }
    @output["fields"].push(h)
    ###

    id = MovementType.find_by_internal_tag("entrega_alumno").id
    movement_types = buildSelectHash2(MovementType,id,"description",false,[])
    h = { "label" => "Motivo","datatype" => "combobox","options" => movement_types }
    @output["fields"].push(h)

    people = []
    h = { "label" => "Entregada a (CI)","datatype" => "select","options" => people, "option" => "personas" }
    h.merge!( { "text_value" => true, "vista" => "movements" } )
    @output["fields"].push(h)
    
    h = { "label" => "Nro. Serie Laptop","datatype" => "select","options" => [],"option" => "laptops" } 
    h.merge!( { "text_value" => true } )
    @output["fields"].push(h)

    h = { "label" => "Nro. Serie Bateria","datatype" => "select","options" => [],"option" => "baterias" } 
    h.merge!( { "text_value" => true } )
    @output["fields"].push(h)

    h = { "label" => "Nro. Serie Cargador","datatype" => "select","options" => [],"option" => "cargadores" } 
    h.merge!( { "text_value" => true } )
    @output["fields"].push(h)

    fecha = ""
    h = { "label" => "Fch. Devolucion","datatype" => "date",  :value => fecha  }
    @output["fields"].push(h)

    h = { "label" => "Observacion", "datatype" => "textarea","width" => 250, "height" => 50 }
    @output["fields"].push(h)
  end

  
  def verify_save
    attribs = getData()
    mov_type_desc = MovementType.find(attribs[:movement_type_id]).description
    personObj = Person.find_by_id_document(attribs[:id_document])
    if !personObj
      raise "No encuentro la persona con documento #{attribs[:id_document]}"
    end
    person_desc = personObj.getFullName()

    str = ""
    str += "Tipo de Entrega: #{mov_type_desc}\n"
    str += "Entregado a: #{person_desc}\n"

    if strNotEmpty(attribs[:serial_number_laptop])
      lapObj = Laptop.find_by_serial_number attribs[:serial_number_laptop]
      if !lapObj
        raise "No encuentro la laptop con numero serial #{attribs[:serial_number_laptop]}"
      end
      owner = lapObj.owner ? lapObj.owner.getFullName() : "nadie"
      str += "Num. Serie Laptop: #{attribs[:serial_number_laptop]} (En manos de #{owner})\n"
    end

    if strNotEmpty(attribs[:serial_number_battery])
      batObj = Battery.find_by_serial_number attribs[:serial_number_battery]
      if !batObj
        str += "Num. Serie Battery: #{attribs[:serial_number_battery]} (No existe)\n"
      else
        owner = batObj.owner ? batObj.owner.getFullName() : "nadie"
        str += "Num. Serie Battery: #{attribs[:serial_number_battery]} (En manos de #{owner})\n"
      end
    end

    if strNotEmpty(attribs[:serial_number_charger])
      chargerObj = Charger.find_by_serial_number attribs[:serial_number_charger]
      if !chargerObj
        str += "Num. Serie Charger: #{attribs[:serial_number_charger]} (No existe)\n"
      else
        owner = chargerObj.owner ? chargerObj.owner.getFullName() : "nadie"
        str += "Num. Serie Charger: #{attribs[:serial_number_charger]} (En manos de #{owner})\n"
      end
    end

    if strNotEmpty(attribs[:return_date])
      str += "Fch Devolucion: #{attribs[:return_date]}\n"
    end
    
    if strNotEmpty(attribs[:comment])
      str += "Comentario: #{attribs[:comment]}\n"
    end

    @output["obj_data"] = str
  end

  def save
    attribs = getData()
    Movement.register(attribs)
    @output["msg"] = "La entrega ha sido registrada"
  end

  def delete
    ids = JSON.parse(params[:payload])
    Movement.cancel(ids)
    @output["msg"] = ids.length == 1 ? "La entrega ha sido anulada" : "Las entregas han sido anulada"
  end


  def report_params
    @output["infoDict"] = Array.new
    MovementType.find(:all).each { |m|
      @output["infoDict"].push( { :label => m.description , :id => m.id } )
    }

    @output["articles"] = Array.new
    @output["articles"].push( { :label => "Laptops" , :id => "laptop" } )
    @output["articles"].push( { :label => "Baterias" , :id => "battery" } )
    @output["articles"].push( { :label => "Cargadores" , :id => "charger" } )
  
  end

  def new_mass_delivery

    @output["window_title"] = "Entrega a alumnos por lote"
    @output["fields"] = []

    id = MovementType.find_by_internal_tag("entrega_alumno").id
    movement_types = buildSelectHash2(MovementType,id,"description",false,[])
    h = { "label" => "Motivo","datatype" => "combobox","options" => movement_types }
    @output["fields"].push(h)

    h = { "label" => "", "datatype" => "dynamic_delivery_form" }
    @output["fields"].push(h)
  end

  def save_mass_delivery
    datos = JSON.parse(params[:payload])
    form_fields = datos["fields"].reverse

    movement_type_id = form_fields.pop
    deliveries = form_fields.pop

    Movement.transaction do
      deliveries.each { |delivery|

        person = Person.find_by_barcode(delivery["person"])
        raise "#{delivery["person"]} no existe." if !person

        laptop = Laptop.find_by_serial_number(delivery["laptop"])
        raise "#{delivery["laptop"]} no existe." if !laptop

        attribs = Hash.new
        attribs[:id_document] = person.getIdDoc()
        attribs[:movement_type_id] = movement_type_id
        attribs[:serial_number_laptop] = laptop.getSerialNumber()
        attribs[:comment] = "Laptops entregadas desde el Formulario dinamico de entregas masivas."
        Movement.register(attribs)
      }
    end
    @output["msg"] = "Las entregas han sido registradas."
  end

  ###
  # When it is needed to deliver a set of laptops to a single person
  def single_mass_delivery
    @output["window_title"] = "Entrega de lote a persona"
    @output["fields"] = []

    movement_types = buildSelectHash2(MovementType,-1,"description",false,[])
    h = { "label" => "Motivo","datatype" => "combobox","options" => movement_types }
    @output["fields"].push(h)

    h = { "label" => "Entregada a (CI)","datatype" => "select","options" => [], "option" => "personas" }
    h.merge!( { "text_value" => true, "vista" => "movements" } )
    @output["fields"].push(h)

    h = { "label" => "Fch. Devolucion","datatype" => "date",  :value => ""  }
    @output["fields"].push(h)

    h = { "label" => "Laptops", "datatype" => "textarea","width" => 250, "height" => 50 }
    @output["fields"].push(h)
  end

  def save_single_mass_delivery
    datos = JSON.parse(params[:payload])
    form_fields = datos["fields"].reverse

    movement_type = MovementType.find_by_id(form_fields.pop)
    person = Person.find_by_id_document(form_fields.pop)

    if movement_type && person
      attribs = Hash.new
      attribs[:id_document] = person.getIdDoc()
      attribs[:movement_type_id] = movement_type.id
      attribs[:comment] = "Laptop entregada desde la ventana de entrega masiva a persona"
      return_date = form_fields.pop
      attribs[:return_date] = return_date if return_date != "" && movement_type.internal_tag == "prestamo"
   
      # Serials Processing
      not_recognised = []
      form_fields.pop.split("\n").each { |serial|

        serial.strip!
        if serial != ""
          laptop = Laptop.find_by_serial_number(serial)
          if laptop
            attribs[:serial_number_laptop] = serial
            Movement.register(attribs)
          else
            not_recognised.push(serial)
          end
        end 
      }
    else
      raise "Los datos son insuficientes!"
    end

    @output["msg"] = "Las entregas han sido registradas"
    if not_recognised != []
      @output["msg"]+= ". Las siguientes laptops no fueron reconocidas por el sistema "
      @output["msg"]+= "("+not_recognised.join(',')+")"
    end
    true
  end

  private

  def getData
    datos = JSON.parse(params[:payload])
    attribs = Hash.new

    data_fields = datos["fields"].reverse

    movement_place = data_fields.pop #Dummy data
    attribs[:movement_type_id] = data_fields.pop
    attribs[:id_document] = data_fields.pop
    attribs[:serial_number_laptop] = data_fields.pop
    attribs[:serial_number_battery] = data_fields.pop
    attribs[:serial_number_charger] = data_fields.pop
    attribs[:return_date] = data_fields.pop
    attribs[:comment] = data_fields.pop

    attribs
  end

  def strNotEmpty(str)
    str && !str.to_s.match(/^ *$/)
  end

end
