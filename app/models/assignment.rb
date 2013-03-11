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

class Assignment < ActiveRecord::Base
  audited

  attr_accessible :source_person_id, :source_person
  attr_accessible :destination_person_id, :destination_person
  attr_accessible :laptop, :laptop_id, :comment

  belongs_to :source_person, :class_name => "Person", :foreign_key => :source_person_id 
  belongs_to :destination_person, :class_name => "Person", :foreign_key => :destination_person_id
  belongs_to :laptop, :class_name => "Laptop", :foreign_key => :laptop_id

  validates_presence_of :laptop_id, :message => N_("Please specify a laptop.")

  FIELDS = [
    {name: _("Assignment Nbr"), column: :id, width: 50, default_sort: :desc},
    {name: _("Assignment Date"), column: :created_at, width: 90},
    {name: _("Laptop serial"), association: :laptop, column: :serial_number, width: 180},
    {name: _("Given by"), association: :source_person, column: :lastname, attribute: :source_person, width:  180},
    {name: _("Given by (Doc ID)"), association: :source_person, column: :id_document, width: 180},
    {name: _("Received by"), association: :destination_person, column: :lastname, attribute: :destination_person, width: 180},
    {name: _("Received (Doc ID)"), association: :destination_person, column: :id_document, width: 180},
    {name: _("Comment"), column: :comment, width: 160},
  ]

  def self.register(attribs)
    attribs = attribs.with_indifferent_access
    Assignment.transaction do
      laptop = Laptop.includes(:status).find(attribs[:laptop_id])

      m = Assignment.new(
        source_person_id: laptop.assignee_id,
        laptop_id: laptop.id,
        comment: attribs[:comment],
      )

      if !attribs[:person_id].blank?
        person = Person.find(attribs[:person_id])
        m.destination_person_id = person.id
      end

      m.save!

      # Move laptop out of "En desuso" for new assignments
      if m.destination_person_id and laptop.status.internal_tag == "deactivated"
        laptop.status = Status.activated
      end

      # Update laptop assignee
      laptop.assignee_id = m.destination_person_id
      laptop.save!
      m
    end
  end

  # Register multiple laptop assignments to the same person, based on laptop SN
  def self.register_many(laptops, attribs)
    count = 0
    Assignment.transaction do
      laptops.each { |serial|
        laptop = Laptop.find_by_serial_number!(serial)
        attribs[:laptop_id] = laptop.id
        Assignment.register(attribs)
        count += 1
      }
    end
    count
  end

  def self.register_barcode_scan(details, attribs)
    attribs = attribs.with_indifferent_access
    count = 0

    Assignment.transaction do
      details.each { |delivery|
        person = Person.find_by_barcode!(delivery["person"])
        laptop = Laptop.find_by_serial_number!(delivery["laptop"])
        attribs[:person_id] = person.id
        attribs[:laptop_id] = laptop.id
        Assignment.register(attribs)
        count += 1
      }
    end
    count
  end

  def getSourcePersonIdDoc()
    self.source_person ? self.source_person.id_document : ""
  end

  def getDestinationPersonIdDoc()
    self.destination_person ? self.destination_person.id_document : ""
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  #
  # In this context, we limit the user to viewing the history of the laptops
  # that are physically within his places. (The other option is to limit the
  # user to viewing assignments that end up within his places, but remember
  # that laptops can also be deassigned, meaning that nobody would be able to
  # see those deassignments)
  def self.setScope(places_ids)
    scope = includes(:laptop => {:owner => {:performs => {:place => :ancestor_dependencies}}})
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    Assignment.with_scope(scope) do
      yield
    end
  end
end
