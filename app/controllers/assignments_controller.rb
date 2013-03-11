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
      form_details_link(_("Created by:"), "people", creator.id, creator.getFullName)
    end

    form_label(_("Assigned at:"), I18n.l(assignment.created_at))

    form_details_link(_("Laptop serial:"), "laptops", assignment.laptop_id, assignment.laptop.serial_number)

    if assignment.source_person
      form_details_link(_("Given by:"), "people", assignment.source_person_id, assignment.source_person.getFullName)
    end

    if assignment.destination_person
      form_details_link(_("Assigned to:"), "people", assignment.destination_person_id, assignment.destination_person.getFullName)
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

    form_select("person_id", "people", _("Assigned to:"))
    form_select("laptop_id", "laptops", _("Serial Number:"))
    form_textarea(nil, "comment", _("Observation"), width: 250, height: 50)
  end
  
  def verify_save
    data = JSON.parse(params[:payload])
    attribs = data["fields"]

    if !attribs["person_id"].blank?
      person_desc = Person.find(attribs["person_id"]).getFullName()
    else
      person_desc = _("Deassigned")
    end

    str = _("Handed to") + ": " + person_desc + "\n"

    if !attribs["laptop_id"].blank?
      laptop = Laptop.find(attribs["laptop_id"])
      owner = laptop.owner ? laptop.owner.getFullName() : _("Nobody")
      str += _("Serial Number") + ": " + laptop.serial_number
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

  def save_mass_assignment
    deliveries = JSON.parse(params[:deliveries])
    comment = _("Laptops assigned with the massive delivery form.")
    count = Assignment.register_barcode_scan(deliveries, comment: comment)
    @output["msg"] = _("%d assignments have been registered.") % count
  end

  # Deliver a set of laptops to a single person
  def single_mass_assignment
    prepare_form(window_title: _("Mass assignment"))
    form_select("person_id", "people", _("Assigned to:"), [])
    form_textarea(nil, "laptops", _("Laptops"), width: 250, height: 50)
  end

  def save_single_mass_assignment
    data = JSON.parse(params[:payload])
    attribs = data["fields"]
    count = Assignment.register_many(attribs["laptops"].split,
                                     person_id: attribs["person_id"],
                                     comment: _("Laptops assigned in mass."))

    @output["msg"] = _("%d assignments have been registered.") % count
  end
end
