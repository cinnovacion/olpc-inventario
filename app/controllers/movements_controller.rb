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
    @include_str = [:source_person, :destination_person, :movement_type, {:movement_details => :laptop}]
  end

  def search
    do_search(Movement,{:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Movement)
    do_search(Movement,{:include => @include_str })
  end

  def new 

    @output["window_title"] = _("Laptop movement")

    @output["fields"] = []

    @output["verify_before_save"] = true
    @output["verify_save_url"] = "/movements/verify_save"

    ### TEST
    #places = buildHierarchyHash(Place, "places", "places.place_id", "name", -1, nil, nil, false)
    #h = { "label" => "Localidad","datatype" => "combobox","options" => places, "vista_widget" => 2, "vista" => "any" }
    #@output["fields"].push(h)
    ###

    id = MovementType.find_by_internal_tag("entrega_alumno").id
    movement_types = buildSelectHash2(MovementType,id,"description",false,[])
    h = { "label" => _("Movement reason"),"datatype" => "combobox","options" => movement_types }
    @output["fields"].push(h)

    people = buildSelectHashSingle(Person, -1, "getFullName()")
    h = { "label" => _("Handed to:"),"datatype" => "select","options" => people, "option" => "personas" }
    @output["fields"].push(h)
    
    h = { "label" => _("Serial Number"),"datatype" => "select","options" => [],"option" => "laptops" } 
    h.merge!( { "text_value" => true } )
    @output["fields"].push(h)

    fecha = ""
    h = { "label" => _("Return date"),"datatype" => "date",  :value => fecha  }
    @output["fields"].push(h)

    h = { "label" => _("Observation"), "datatype" => "textarea","width" => 250, "height" => 50 }
    @output["fields"].push(h)
  end

  
  def verify_save
    attribs = getData()
    mov_type_desc = MovementType.find(attribs[:movement_type_id]).description
    personObj = Person.find_by_id_document(attribs[:id_document])
    if !personObj
      raise _("Can't find person with document id ") + attribs[:id_document].to_s
    end
    person_desc = personObj.getFullName()

    str = ""
    str += _("Movement reason") + " : " + mov_type_desc  + "\n"
    str += _("Handed to") + " : " + person_desc + "\n"

    if strNotEmpty(attribs[:serial_number_laptop])
      lapObj = Laptop.find_by_serial_number attribs[:serial_number_laptop]
      if !lapObj
        raise _("Can't find laptop with serial number") + attribs[:serial_number_laptop].to_s
      end
      owner = lapObj.owner ? lapObj.owner.getFullName() : "nadie"
      str += _("Serial Number") +  attribs[:serial_number_laptop].to_s 
      str += " (" + _("Owned by ") + owner + ")\n"
    end

    if strNotEmpty(attribs[:return_date])
      str += _("Return date:") +  attribs[:return_date] + "\n"
    end
    
    if strNotEmpty(attribs[:comment])
      str += _("Comment:") +  attribs[:comment] + "\n"
    end

    @output["obj_data"] = str
  end

  def save
    attribs = getData()
    Movement.register(attribs)
    @output["msg"] = _("The movement has been registered.")
  end

  def delete
    ids = JSON.parse(params[:payload])
    Movement.cancel(ids)
    @output["msg"] = ids.length == 1 ? _("The movement has been cancelled") : _("The movements have been cancelled")
  end


  def report_params
    @output["infoDict"] = Array.new
    MovementType.find(:all).each { |m|
      @output["infoDict"].push( { :label => m.description , :id => m.id } )
    }

    @output["articles"] = Array.new
    @output["articles"].push( { :label => "Laptops" , :id => "laptop" } )
  end

  def new_mass_delivery

    @output["window_title"] = _("Movement by lot")
    @output["fields"] = []

    h = { "label" => _("Note"), "datatype" => "label", "text" => _("This form is for creating <b>movements</b> of laptops in mass. For each movement you wish to create, scan the barcode of the person and the barcode (serial number) of the laptop.") }
    @output["fields"].push(h)

    id = MovementType.find_by_internal_tag("entrega_alumno").id
    movement_types = buildSelectHash2(MovementType, id, "description", false, [])
    h = { "label" => _("Reason"), "datatype" => "combobox", "options" => movement_types }
    @output["fields"].push(h)

    h = { "label" => "", "datatype" => "dynamic_delivery_form", "mode" => "movement" }
    @output["fields"].push(h)
  end

  def save_mass_delivery
    datos = JSON.parse(params[:payload])
    form_fields = datos["fields"].reverse

    movement_type_id = form_fields.pop
    deliveries = form_fields.pop

    Movement.transaction do
      deliveries.each { |delivery|

        if delivery["person"] and delivery["laptop"]
          person = Person.find_by_barcode(delivery["person"])
          raise _("%s doesn't exist.") % delivery["person"].to_s if !person

          laptop = Laptop.find_by_serial_number(delivery["laptop"])
          raise _("The laptop with serial number %s doesn't exist.") % delivery["laptop"] if !laptop

          attribs = Hash.new
          attribs[:id_document] = person.getIdDoc()
          attribs[:movement_type_id] = movement_type_id
          attribs[:serial_number_laptop] = laptop.getSerialNumber()
          attribs[:comment] = _("Laptops moved out with the mass movement form.")
          Movement.register(attribs)
        end
      }
    end
    @output["msg"] = _("The movements have been registered.")
  end

  def new_handout

    @output["window_title"] = _("Register handout")
    @output["fields"] = []

    id = MovementType.find_by_internal_tag("entrega_alumno").id
    movement_types = buildSelectHash2(MovementType, id, "description", false, [])
    h = { "label" => "Note", "text" => _("Use this form to mark laptops as handed out. For each laptop, a movement will be created, from the current owner to the respective assignee."), "datatype" => "label" }
    @output["fields"].push(h)

    h = { "label" => _("Reason"), "datatype" => "combobox", "options" => movement_types }
    @output["fields"].push(h)

    h = { "label" => _("Laptops"), "datatype" => "textarea","width" => 250, "height" => 50 }
    @output["fields"].push(h)

    h = { "label" => _("Observation"),"datatype" => "textfield" }
    @output["fields"].push(h)
  end

  def save_handout
    datos = JSON.parse(params[:payload])
    form_fields = datos["fields"].reverse
    movement_type_id = form_fields.pop
    laptops = form_fields.pop
    observation = form_fields.pop.strip

    if observation == ""
      observation = _("Laptop handout")
    end

    attribs = Hash.new
    attribs[:movement_type_id] = movement_type_id 
    attribs[:comment] = observation
   
    not_recognised = []
    laptops.split(" ").each { |serial|
      serial.strip!
      if serial == ""
        next
      end

      serial.upcase!
      laptop = Laptop.find_by_serial_number(serial)
      if laptop
        if !laptop.assignee
          raise _("Laptop #{serial} is unassigned.")
        end
        next if laptop.owner == laptop.assignee

        attribs[:id_document] = laptop.getAssigneeIdDoc()
        attribs[:serial_number_laptop] = serial
        Movement.register(attribs)
      else
        not_recognised.push(serial)
      end
    }

    @output["msg"] = _("The movements have been registered.")
    if not_recognised != []
      @output["msg"]+= "." + _("The following laptops weren't recognized ")
      @output["msg"]+= "("+not_recognised.join(',')+")"
    end
    true
  end

  ###
  # When it is needed to deliver a set of laptops to a single person
  #
  def single_mass_delivery
    @output["window_title"] = _("Movement by lot")
    @output["fields"] = []

    id = MovementType.find_by_internal_tag("entrega_alumno").id
    movement_types = buildSelectHash2(MovementType, id, "description", false, [])
    h = { "label" => _("Reason"), "datatype" => "combobox", "options" => movement_types }
    @output["fields"].push(h)

    people = buildSelectHashSingle(Person, -1, "getFullName()")
    h = { "label" => _("Handed to:"), "datatype" => "select", "options" => people, "option" => "personas" }
    @output["fields"].push(h)

    h = { "label" => _("Return date:"),"datatype" => "date",  :value => ""  }
    @output["fields"].push(h)

    h = { "label" => _("Laptops"), "datatype" => "textarea","width" => 250, "height" => 50 }
    @output["fields"].push(h)
  end

  def save_single_mass_delivery
    datos = JSON.parse(params[:payload])
    form_fields = datos["fields"].reverse

    movement_type = MovementType.find_by_id(form_fields.pop)
    person = Person.find_by_id(form_fields.pop)

    if movement_type && person
      attribs = Hash.new
      attribs[:id_document] = person.getIdDoc()
      attribs[:movement_type_id] = movement_type.id 
      attribs[:comment] = _("Laptops moved out with the mass movement form.")
      return_date = form_fields.pop
      attribs[:return_date] = return_date if return_date != "" && movement_type.internal_tag == "prestamo"
   
      # Serials Processing
      not_recognised = []
      form_fields.pop.split("\n").each { |serial|

        serial.strip!
        if serial != ""
          laptop = Laptop.find_by_serial_number(serial)
          if laptop
            if laptop.owner_id != person.id
              attribs[:serial_number_laptop] = serial
              Movement.register(attribs)
            end
          else
            not_recognised.push(serial)
          end
        end 
      }
    else
      raise _("Insufficient data given!")
    end

    @output["msg"] = _("The movements have been registered.")
    if not_recognised != []
      @output["msg"]+= "." + _("The following laptops weren't recognized ")
      @output["msg"]+= "("+not_recognised.join(',')+")"
    end
    true
  end

  private

  def getData
    datos = JSON.parse(params[:payload])
    attribs = Hash.new

    data_fields = datos["fields"].reverse

    #movement_place = data_fields.pop #Dummy data
    attribs[:movement_type_id] = data_fields.pop

    personObj = Person.find_by_id(data_fields.pop)
    if !personObj
      raise _("Can't find person")
    end

    attribs[:id_document] = personObj.id_document
    attribs[:serial_number_laptop] = data_fields.pop
    attribs[:return_date] = data_fields.pop
    attribs[:comment] = data_fields.pop

    attribs
  end

  ###
  # FIXME: Isn't this used somewhere else? If so it should be moved to ApplicationController 
  #        or to a lib. 
  #
  def strNotEmpty(str)
    str && !str.to_s.match(/^ *$/)
  end

end
