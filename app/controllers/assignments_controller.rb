#     Copyright Paraguay Educa 2009
#     Copyright Daniel Drake 2010
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

class AssignmentsController < SearchController
  skip_filter :rpc_block, :only => [ :show, :create, :update, :destroy, :index ]

  def index
     render :xml => Assignment.all.to_xml
  end
 
  def show
    as = Assignment.find_by_id(params["id"])
    render :xml => as.to_xml
  end

  def create
    Assignment.register(params[:as])
    as = Assignment.find(params[:as])
    render :xml => as.to_xml, :status => :created
  end

  def update
    as = Assignment.find_by_id(params["id"])
    as.update_attributes(params[:assignment])
    render :xml => as.to_xml, :status => :ok
  end

  def destroy
    Assignment.destroy(params["id"])
    render :status => :ok
  end

  attr_accessor :include_str

  def initialize
    super 
    @include_str = [:source_person, :destination_person, :laptop]
  end

  def search
    do_search(Assignment,{:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Assignment)
    do_search(Assignment,{:include => @include_str })
  end

  def details(id)
    @output["window_title"] = _("Assignment details")
    @output["fields"] = []

    assignment = Assignment.includes(:laptop, :source_person, :destination_person).find(id)
    if !assignment
      raise _("Cannot find assignment.")
    end

    h = { "datatype" => "label", "label" => _("Assignment number:"), :text => assignment.id }
    @output["fields"].push(h)

    h = { "datatype" => "label", "label" => _("Assigned at:"), :text => assignment.getAssignmentDate + " " + assignment.getAssignmentTime }
    @output["fields"].push(h)

    h = { "label" => _("Laptop serial:"), :datatype => "abmform_details", :option => "laptops", :id => assignment.laptop_id, :text => assignment.laptop.serial_number }
    @output["fields"].push(h)

    if assignment.source_person
      h = { "label" => _("Given by:"), :datatype => "abmform_details", :option => "personas", :id => assignment.source_person_id, :text => assignment.source_person.getFullName() }
      @output["fields"].push(h)
    end

    if assignment.destination_person
      h = { "label" => _("Assigned to:"), :datatype => "abmform_details", :option => "personas", :id => assignment.destination_person_id, :text => assignment.destination_person.getFullName() }
      @output["fields"].push(h)
    end

    h = { "datatype" => "label", "label" => _("Comment:"), :text => assignment.comment }
    @output["fields"].push(h)
  end

  def new
    if params[:id]
      details(params[:id])
      return
    end

    @output["window_title"] = _("Assign Laptop")

    @output["fields"] = []

    @output["verify_before_save"] = true
    @output["verify_save_url"] = "/assignments/verify_save"

    ### TEST
    #places = buildHierarchyHash(Place, "places", "places.place_id", "name", -1, nil, nil, false)
    #h = { "label" => "Localidad","datatype" => "combobox","options" => places, "vista_widget" => 2, "vista" => "any" }
    #@output["fields"].push(h)
    ###

    people = buildSelectHashSingle(Person, -1, "getFullName()")
    h = { "label" => _("Assigned to:"),"datatype" => "select","options" => people, "option" => "personas" }
    @output["fields"].push(h)
    
    h = { "label" => _("Serial Number"),"datatype" => "select","options" => [],"option" => "laptops" } 
    h.merge!( { "text_value" => true } )
    @output["fields"].push(h)

    h = { "label" => _("Observation"), "datatype" => "textarea","width" => 250, "height" => 50 }
    @output["fields"].push(h)
  end

  
  def verify_save
    attribs = getData()
    personObj = Person.find_by_id_document(attribs[:id_document])
    if !personObj
      person_desc = _("Deassigned")
    else
      person_desc = personObj.getFullName()
    end

    str = ""
    str += _("Handed to") + " : " + person_desc + "\n"

    if strNotEmpty(attribs[:serial_number_laptop])
      lapObj = Laptop.find_by_serial_number attribs[:serial_number_laptop]
      if !lapObj
        raise _("Can't find laptop with serial number") + attribs[:serial_number_laptop].to_s
      end
      owner = lapObj.owner ? lapObj.owner.getFullName() : "nadie"
      str += _("Serial Number") +  attribs[:serial_number_laptop].to_s 
      str += " (" + _("in hands of ") + owner + ")\n"
    end

    if strNotEmpty(attribs[:comment])
      str += _("Comment:") +  attribs[:comment] + "\n"
    end

    @output["obj_data"] = str
  end

  def save
    attribs = getData()
    Assignment.register(attribs)
    @output["msg"] = _("The assignment has been registered.")
  end

  def delete
    ids = JSON.parse(params[:payload])
    Assignment.delete(ids)
    @output["msg"] = ids.length == 1 ? _("The assignment has been cancelled") : _("The assignments have been cancelled")
  end


  def report_params
    @output["articles"] = Array.new
    @output["articles"].push( { :label => "Laptops" , :id => "laptop" } )
  end

  def saveMassAssignment
    deliveries = JSON.parse(params[:deliveries])

    Assignment.transaction do
      deliveries.each { |delivery|

        person = Person.find_by_barcode(delivery["person"])
        raise _("%s doesn't exist.") % delivery["person"].to_s if !person

        laptop = Laptop.find_by_serial_number(delivery["laptop"])
        raise _("The laptop with serial number %s doesn't exist.") % delivery["laptop"] if !laptop

        attribs = Hash.new
        attribs[:id_document] = person.getIdDoc()
        attribs[:serial_number_laptop] = laptop.getSerialNumber()
        attribs[:comment] = _("Laptops assigned with the massive delivery form.")
        Assignment.register(attribs)
      }
    end
    @output["msg"] = _("The assignments have been registered.")
  end

  ###
  # When it is needed to deliver a set of laptops to a single person
  #
  def single_mass_assignment
    @output["window_title"] = _("Mass assignment.")
    @output["fields"] = []

    people = buildSelectHashSingle(Person, -1, "getFullName()")
    h = { "label" => _("Assigned to:"), "datatype" => "select", "options" => people, "option" => "personas" }
    @output["fields"].push(h)

    h = { "label" => _("Laptops"), "datatype" => "textarea","width" => 250, "height" => 50 }
    @output["fields"].push(h)
  end

  def save_single_mass_assignment
    datos = JSON.parse(params[:payload])
    form_fields = datos["fields"].reverse

    attribs = Hash.new

    person = Person.find_by_id(form_fields.pop)
    attribs[:id_document] = person.getIdDoc() if person

    attribs[:comment] = _("Laptops assigned in mass.")
   
    # Serials Processing
    not_recognised = []
    form_fields.pop.split("\n").each { |serial|

      serial.strip!
      if serial != ""
        laptop = Laptop.find_by_serial_number(serial)
        if laptop
          attribs[:serial_number_laptop] = serial
          Assignment.register(attribs)
        else
          not_recognised.push(serial)
        end
      end 
    }

    @output["msg"] = _("The assignments have been registered.")
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

    person_id = data_fields.pop
    if person_id and person_id != ""
      personObj = Person.find_by_id(person_id)
      if !personObj
        raise _("Can't find person")
      end

      attribs[:id_document] = personObj.id_document
    end

    attribs[:serial_number_laptop] = data_fields.pop
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
