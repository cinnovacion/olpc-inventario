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

require 'lib/fecha'

class Assignment < ActiveRecord::Base
  belongs_to :source_person, :class_name => "Person", :foreign_key => :source_person_id 
  belongs_to :destination_person, :class_name => "Person", :foreign_key => :destination_person_id
  belongs_to :laptop, :class_name => "Laptop", :foreign_key => :laptop_id

  
  validates_presence_of :laptop_id, :message => _("Please specify a laptop.")


  def self.getColumnas()
    ret = Hash.new
    ret[:columnas] = [ 
     {:name => _("Assignment Nbr"),:key => "assignments.id",:related_attribute => "id", :width => 50},
     {:name => _("Assignment Date"),:key => "assignments.date_assigned",:related_attribute => "getAssignmentDate()", :width => 90},
     {:name => _("Assignment Time"),:key => "assignments.time_assigned",:related_attribute => "getAssignmentTime()", :width => 90},
     {:name => _("Laptop serial"),:key => "laptops.serial_number",:related_attribute => "getSerialNumber()", :width => 180},
     {:name => _("Given by"),:key => "people.name",:related_attribute => "getSourcePerson()", :width => 180},
     {:name => _("Given by (Doc ID)"),:key => "people.id_document",:related_attribute => "getSourcePersonIdDoc()", :width => 180},
     {:name => _("Received by"),:key => "destination_people_assignments.name",:related_attribute => "getDestinationPerson()", :width => 180},
     {:name => _("Received (Doc ID)"),:key => "destination_people_assignments.id_document",:related_attribute => "getDestinationPersonIdDoc()", :width => 180},
     {:name => _("Comment"),:key => "assignments.comment",:related_attribute => "getComment()", :width => 160}
    ]
    ret[:sort_column] = 0
    ret
  end

  
  def self.register(attribs)
    Assignment.transaction do


      m = Assignment.new
      
      lapObj = Laptop.find_by_serial_number(attribs[:serial_number_laptop])
      m.source_person_id = lapObj.assignee_id
      m.laptop_id = lapObj.id

      if attribs[:id_document] and attribs[:id_document] != "":
        personObj = Person.find_by_id_document(attribs[:id_document])
        if !personObj
          raise _("Couldn't find person with document ID %s") % attribs[:id_document]
        end
        m.destination_person_id = personObj.id
      else
        m.destination_person_id = nil
      end

      m.comment = attribs[:comment]
      m.save!

      #Updating assignee
      lapObj.assignee_id = m.destination_person_id
      lapObj.save!

    end
  end

  def before_save
    self.created_at = self.date_assigned = self.time_assigned = Time.now
  end

  def getSerialNumber()
    self.laptop.serial_number
  end
 
  def getAssignmentDate()
    self.date_assigned.to_s
  end

  def getAssignmentTime()
    Fecha::getHora(self.time_assigned)
  end

  def getSourcePerson()
    self.source_person ? self.source_person.getFullName() : ""
  end

  def getSourcePersonIdDoc()
    self.source_person ? self.source_person.getIdDoc() : ""
  end

  def getDestinationPerson()
    self.destination_person ? self.destination_person.getFullName() : ""
  end

  def getDestinationPersonIdDoc()
    self.destination_person ? self.destination_person.getIdDoc() : ""
  end

  def getComment()
    self.comment
  end

  def getParts()
    s = String.new
    self.assignment_details.each { |p|
      s+= "#{p.description},"
    }
    s
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
    find_include = [:laptop => {:owner => {:performs => {:place => :ancestor_dependencies}}}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    Assignment.with_scope(scope) do
      yield
    end
  end

end
