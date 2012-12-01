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

require 'fecha'

class Movement < ActiveRecord::Base
  acts_as_audited

  belongs_to :laptop
  belongs_to :source_person, :class_name => "Person", :foreign_key => :source_person_id 
  belongs_to :destination_person, :class_name => "Person", :foreign_key => :destination_person_id
  belongs_to :movement_type 

  attr_accessible :responsible_person, :responsible_person_id
  attr_accessible :source_person, :source_person_id
  attr_accessible :destination_person, :destination_person_id
  attr_accessible :movement_type, :movement_type_id
  attr_accessible :laptop, :laptop_id
  attr_accessible :comment, :return_date, :returned


  validates_presence_of :source_person_id, :message => N_("Please specify who delivered.")
  validates_presence_of :destination_person_id, :message => N_("Please specify who gets it.")

  before_save :do_before_save
  after_save :handle_returns

  def self.getColumnas()
    {
    columnas: [ 
     {name: _("Mov. Nbr"), key: "movements.id", related_attribute: "id", width: 50},
     {name: _("Mov. Date"), key: "movements.date_moved_at", related_attribute: "date_moved_at", width: 90},
     {name: _("Mov. Time"), key: "movements.time_moved_at", related_attribute: "movement_time", width: 90},
     {name: _("Type"), key: "movement_types.description", related_attribute: "movement_type", width: 150},
     {name: _("Serial Nbr"), key: "laptops.serial_number", related_attribute: "laptop.serial_number", width: 150},
     {name: _("Given by"), key: "people.name", related_attribute: "source_person", width: 180},
     {name: _("Given (Doc id)"), key: "people.id_document", related_attribute: "source_person.id_document", width: 180},
     {name: _("Received by"), key: "destination_people_movements.name", related_attribute: "destination_person", width: 180},
     {name: _("Received (Doc id)"), key: "destination_people_movements.id_document", related_attribute: "destination_person.id_document", width: 180},
     {name: _("Comment"), key: "movements.comment", related_attribute: "comment", width: 160}
    ],
    sort_column: 0
    }
  end

  def self.register(attribs)
    attribs = attribs.with_indifferent_access
    Movement.transaction do
      device_status = nil

      if attribs[:movement_type_id].blank?
        movement_type = MovementType.find_by_internal_tag!("entrega_alumno")
      else
        movement_type = MovementType.find_by_id!(attribs[:movement_type_id])
      end

      if movement_type.is_repair?
        device_status = Status.find_by_internal_tag("on_repair")
      elsif movement_type.is_delivery?
        device_status = Status.find_by_internal_tag("activated")
      elsif movement_type.is_return?
        device_status = Status.find_by_internal_tag("deactivated")
      end

      laptop = Laptop.find(attribs[:laptop_id])
      person = Person.find(attribs[:person_id])
      last_movement_type = laptop.last_movement_type
      m = Movement.new(
        laptop_id: laptop.id,
        source_person_id: laptop.owner_id,
        destination_person_id: person.id,
        comment: attribs[:comment],
        movement_type_id: movement_type.id
      )
      if !attribs[:return_date].blank? and movement_type.is_loan?
        m.return_date = attribs[:return_date]
      end
      m.save!

      # Check movements FSM
      if !MovementType.check(last_movement_type, movement_type)
        error_str = "The movement carried on %s does not match latest move," % m.laptop.serial_number
        error_str += "the previous move was %s" % last_movement_type.description
        raise error_str
      end

      laptop.owner_id = m.destination_person_id
      laptop.status_id = device_status.id if device_status
      laptop.save!

      m
    end
  end

  # Register multiple laptop movements to the same person, based on laptop SN
  def self.register_many(laptops, attribs)
    attribs = attribs.with_indifferent_access
    not_recognised = []
    count = 0

    Movement.transaction do
      laptops.each { |serial|
        laptop = Laptop.find_by_serial_number(serial)
        if !laptop
          not_recognised.push(serial)
          next
        end

        if laptop.owner_id != attribs[:person_id]
          attribs[:laptop_id] = laptop.id
          Movement.register(attribs)
          count += 1
        end
      }
    end

    return count, not_recognised
  end

  # Register movements based on a barcode scan of person barcode and laptop SN
  def self.register_barcode_scan(details, attribs)
    attribs = attribs.with_indifferent_access
    count = 0
    Movement.transaction do
      details.each { |delivery|
        next if !delivery["person"] or !delivery["laptop"]
        person = Person.find_by_barcode!(delivery["person"])
        laptop = Laptop.find_by_serial_number!(delivery["laptop"])
        attribs[:person_id] = person.id
        attribs[:laptop_id] = laptop.id
        Movement.register(attribs)
        count += 1
      }
    end
    count
  end

  # Register a laptop handout by setting owner = assignee for a set of laptops
  def self.register_handout(laptop_serials, attribs)
    not_recognised = []
    attribs = attribs.with_indifferent_access

    attribs[:comment] = _("Laptop handout") if attribs[:comment].blank?

    count = 0
    laptop_serials.each { |serial|
      laptop = Laptop.includes(:assignee).find_by_serial_number(serial)
      if !laptop
        not_recognised.push(serial)
        next
      end

      raise _("Laptop #{serial} is unassigned.") if !laptop.assignee_id
      next if laptop.owner_id == laptop.assignee_id

      attribs[:person_id] = laptop.assignee.id
      attribs[:laptop_id] = laptop.id
      Movement.register(attribs)
      count += 1
    }

    return count, not_recognised
  end

  def do_before_save
    raise _("Loans require a return date.") if !return_date and movement_type.is_loan?
    raise _("Only loans require return date.") if return_date and !movement_type.is_loan?
    # FIXME make created_at datetime, combine moved_at info there, drop
    # moved_info, drop this assignment, and let rails do the work
    self.created_at = self.date_moved_at = self.time_moved_at = Time.now
  end

  def handle_returns
    return if !movement_type.is_return?

    details = Movement.includes(:movement_type)
    details = details.where(:returned => false)
    details = details.where('movement_types.internal_tag' => 'prestamo')
    details = details.where('laptop_id' => laptop.id)

    movement = details.order("movements.id DESC").first
    movement.update_attributes!(returned: true) if movement
  end
  
  def movement_time
    Fecha::getHora(self.time_moved_at)
  end

  def creator
    if audits and audits.first and audits.first.user
      return audits.first.user.person
    end
  end

  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  #
  # In this context, we limit the user to viewing the history of the laptops
  # that are physically within his places. (This matches the behaviour of
  # the assignments model, where there is no other viable option)
  def self.setScope(places_ids)
    scope = includes(:laptop => {:owner => {:performs => {:place => :ancestor_dependencies}}})
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    Movement.with_scope(scope) do
      yield
    end
  end
end
