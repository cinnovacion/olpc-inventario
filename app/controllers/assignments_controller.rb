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

class AssignmentsController < SearchController
  undef_method :delete

  def initialize
    super(:includes => [:source_person, :destination_person, :laptop])
  end

  def details
    assignment = prepare_form(window_title: _("Assignment details"))
    if !assignment
      raise _("Cannot find assignment.")
    end

    form_label(_("Assignment number:"), assignment.id)

    if assignment.audits and assignment.audits.first and assignment.audits.first.user
      creator = assignment.audits.first.user.person
      form_details_link(_("Created by:"), "personas", creator.id, creator.getFullName)
    end

    form_label(_("Assigned at:"), assignment.date_assigned.to_s + " " + assignment.getAssignmentTime)

    form_details_link(_("Laptop serial:"), "laptops", assignment.laptop_id, assignment.laptop.serial_number)

    if assignment.source_person
      form_details_link(_("Given by:"), "personas", assignment.source_person_id, assignment.source_person.getFullName)
    end

    if assignment.destination_person
      form_details_link(_("Assigned to:"), "personas", assignment.destination_person_id, assignment.destination_person.getFullName)
    end

    form_label(_("Comment:"), assignment.comment)
  end

  def new
    if params[:id]
      details
      return
    end

    prepare_form(window_title: _("Assign Laptop"),
                 verify_before_save: true,
                 verify_save_url: "/assignments/verify_save")

    form_select("person_id", "personas", _("Assigned to:"), [])
    form_select("serial_number_laptop", "laptops", _("Serial Number:"), [], text_value: true)
    form_textarea(nil, "comment", _("Observation"), width: 250, height: 50)
  end
  
  def verify_save
    data = JSON.parse(params[:payload])
    attribs = data["fields"]

    # FIXME check person_id for deassigning, is it 0 or blank?
    if !attribs["person_id"].blank?
      person_desc = Person.find(attribs["person_id"]).getFullName()
    else
      person_desc = _("Deassigned")
    end

    str = _("Handed to") + ": " + person_desc + "\n"

    if !attribs["serial_number_laptop"].blank?
      lapObj = Laptop.find_by_serial_number attribs["serial_number_laptop"]
      if !lapObj
        raise _("Can't find laptop with serial number") + attribs["serial_number_laptop"]
      end
      owner = lapObj.owner ? lapObj.owner.getFullName() : _("Nobody")
      str += _("Serial Number") + ": " + attribs["serial_number_laptop"]
      str += " (" + _("in hands of ") + owner + ")\n"
    end

    if !attribs["comment"].blank?
      str += _("Comment:") +  attribs["comment"] + "\n"
    end

    @output["obj_data"] = str
  end

  def save
    data = JSON.parse(params[:payload])
    attribs = data["fields"]
    Assignment.register(attribs)
    @output["msg"] = _("The assignment has been registered.")
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
        raise _("%s doesn't exist.") % delivery["person"] if !person

        attribs = Hash.new
        attribs[:person_id] = person.id
        attribs[:serial_number_laptop] = delivery["laptop"]
        attribs[:comment] = _("Laptops assigned with the massive delivery form.")
        Assignment.register(attribs)
      }
    end
    @output["msg"] = _("The assignments have been registered.")
  end

  # Deliver a set of laptops to a single person
  def single_mass_assignment
    prepare_form(window_title: _("Mass assignment"))
    form_select("person_id", "personas", _("Assigned to:"), [])
    form_textarea(nil, "laptops", _("Laptops"), width: 250, height: 50)
  end

  def save_single_mass_assignment
    data = JSON.parse(params[:payload])
    attribs = data["fields"]

    attribs["laptops"].split.each { |serial|
      Assignment.register(serial_number_laptop: serial,
                          person_id: attribs["person_id"],
                          comment: _("Laptops assigned in mass."))
    }

    @output["msg"] = _("The assignments have been registered.")
  end
end
