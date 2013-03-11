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
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 

class MovementsController < SearchController
  skip_filter :rpc_block, :only => [ :show, :create, :update, :index ]
  undef_method :delete

  def initialize
    includes = [:source_person, :destination_person, :movement_type, :laptop]
    super(:includes => includes)
  end

  def index
     render :xml => Movement.all.to_xml
  end
 
  def show
    render :xml => Movement.find(params["id"]).to_xml
  end

  def create
    mov = Movement.register!(params[:movement])
    render :xml => mov.to_xml, :status => :created
  end

  def update
    mov = Movement.find(params["id"])
    mov.update_attributes!(params[:movement])
    render :xml => mov.to_xml, :status => :ok
  end

  def details(id)
    movement = Movement.includes(:source_person, :destination_person)
    movement = prepare_form(window_title: _("Movement details"), relation: movement)

    form_label(_("Movement number:"), movement.id)

    creator = movement.creator
    if creator
      form_details_link(_("Created by:"), :people, creator.id, creator)
    end

    form_label(_("Movement date:"), movement.created_at)
    form_label(_("Movement type:"), movement.movement_type)

    form_details_link(_("Laptop serial:"), :laptops, movement.laptop_id, movement.laptop.serial_number)

    if movement.source_person
      form_details_link(_("Given by:"), :people, movement.source_person_id, movement.source_person)
    end

    if movement.destination_person
      form_details_link(_("Received by:"), :people, movement.destination_person_id, movement.destination_person)
    end

    form_label(_("Comment:"), movement.comment)
  end

  def new
    if params[:id]
      details(params[:id])
      return
    end

    prepare_form(window_title: _("Laptop movement"),
                 verify_before_save: true,
                 verify_save_url: "/movements/verify_save")

    id = MovementType.find_by_internal_tag!("entrega_alumno").id
    movement_types = buildSelectHash2(MovementType, id, "description", false, [])
    form_combobox(nil, "movement_type_id", _("Movement reason"), movement_types)

    people = buildSelectHashSingle(Person, -1, "getFullName")
    form_select("person_id", "people", _("Person"), people)
    form_select("laptop_id", "laptops", _("Laptop"), [])

    form_date(nil, "return_date", _("Return date"))
    form_textarea(nil, "comment", _("Comment"), width: 250, height: 50)
  end
  
  def verify_save
    data = JSON.parse(params[:payload])
    attribs = data["fields"]

    mov_type_desc = MovementType.find(attribs["movement_type_id"]).description
    person = Person.find(attribs["person_id"])

    str  = _("Movement reason") + " : " + mov_type_desc  + "\n"
    str += _("Handed to") + " : " + person.getFullName() + "\n"

    if !attribs["laptop_id"].blank?
      laptop = Laptop.find(attribs["laptop_id"])
      str += _("Serial Number") + " " + laptop.serial_number
      str += " (" + _("Owned by ") + laptop.owner.to_s + ")\n"
    end

    if !attribs["return_date"].blank?
      str += _("Return date:") + " " + attribs["return_date"] + "\n"
    end
    
    if !attribs["comment"].blank?
      str += _("Comment:") + " " + attribs["comment"] + "\n"
    end

    @output["obj_data"] = str
  end

  def save
    data = JSON.parse(params[:payload])
    Movement.register(data["fields"])
    @output["msg"] = _("The movement has been registered.")
  end

  def save_mass_movement
    deliveries = JSON.parse(params[:deliveries])
    movement_type_id = params[:movement_type]
    comment = _("Laptops moved out with the mass movement form.")
    count = Movement.register_barcode_scan(deliveries,
                                           movement_type_id: movement_type_id,
                                           comment: comment)
    @output["msg"] = _("%d movements have been registered.") % count
  end

  # Create movements based on laptop's assignees to complete a laptop handout
  def register_handout
    data = JSON.parse(params[:payload])
    attribs = {
      movement_type_id: data["movement_type"],
      comment: data["comment"]
    }

    laptops = data["to_register"]
    if !laptops.respond_to?("each")
      laptops = []
      data["to_register"].split.each { |serial| laptops.push(serial.upcase) }
    end

    count, not_recognised = Movement.register_handout(laptops, attribs)

    @output["msg"] = _("#{count} movements have been registered.")
    if !not_recognised.empty?
      @output["msg"]+= "." + _("The following laptops weren't recognized ")
      @output["msg"]+= "("+not_recognised.join(',')+")"
    end
  end

  # Deliver a set of laptops to a single person
  def single_mass_delivery
    prepare_form(window_title: _("Movement by lot"))

    id = MovementType.find_by_internal_tag!("entrega_alumno").id
    movement_types = buildSelectHash2(MovementType, id, "description", false, [])
    form_combobox(nil, "movement_type_id", _("Reason"), movement_types)

    people = buildSelectHashSingle(Person, -1, "getFullName")
    form_select("person_id", "people", _("Handed to:"), people)

    form_date(nil, "return_date", _("Return date"))
    form_textarea(nil, "laptops", _("Laptops"), width: 250, height: 50)
  end

  def save_single_mass_delivery
    data = JSON.parse(params[:payload])
    attribs = data["fields"]
    laptops = attribs["laptops"].split
    attribs.delete("laptops")
    attribs["comment"] = _("Laptops moved out with the mass movement form.")
    count, not_recognised = Movement.register_many(laptops, attribs)

    @output["msg"] = _("%d movements have been registered.") % count
    if not_recognised != []
      @output["msg"]+= "." + _("The following laptops weren't recognized ")
      @output["msg"]+= "("+not_recognised.join(',')+")"
    end
  end
end
