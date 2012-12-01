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
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #
                                                                          
class ProblemReport < ActiveRecord::Base
  belongs_to :problem_type
  belongs_to :person
  belongs_to :owner, :class_name => "Person", :foreign_key => :owner_id
  belongs_to :place
  belongs_to :laptop
  has_one :problem_solution

  attr_accessible :problem_type, :problem_type_id
  attr_accessible :person, :person_id
  attr_accessible :owner, :owner_id
  attr_accessible :place, :place_id
  attr_accessible :laptop, :laptop_id
  attr_accessible :solved, :comment, :solved_at

  validates_presence_of :problem_type_id, :message => N_("You must provide the type of problem.")
  validates_presence_of :laptop_id, :message => N_("You must provide the laptop linked to the problem.")
  validates_presence_of :place_id, :message => N_("You must provide the location of the owner.")
  validates_presence_of :owner_id, :message => N_("You must provide the owner.")

  before_create :set_created_at
  after_create :register_notifications
  before_validation :sync_laptop_details

  def self.getColumnas()
    [ 
     {:name => _("Id"), :key => "problem_reports.id", :related_attribute => "getId()", :width => 50},
     {:name => _("Technician CI"), :key => "people.id_document", :related_attribute => "getTechnicianIdDoc()", :width => 120},
     {:name => _("Type"), :key => "problem_types.name", :related_attribute => "getProblemName()", :width => 120},
     {:name => _("Laptop"), :key => "laptops.serial_number", :related_attribute => "getLaptopSerialNumber()", :width => 120},
     {:name => _("Place"), :key => "places.name", :related_attribute => "getParentPlaceName", :width => 120},
     {:name => _("Report Date"), :key => "problem_reports.created_at", :related_attribute => "getDate()", :width => 120},
     {:name => _("Solved"), :key => "problem_reports.solved", :related_attribute => "getSolvedStatus()", :width => 120},
     {:name => _("Solved at"), :key => "problem_reports.solved_at", :related_attribute => "getSolvedDate()", :width => 120},
     {:name => _("Comment"), :key => "problem_reports.comment", :related_attribute => "getComment()", :width => 120}
    ]
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new
    ret["desc_col"] = 0
    ret["id_col"] = 0
    ret
  end

  def sync_laptop_details
    # Since we need a lot of statistical information,
    # we cannot rely on laptops data to deduce the
    # owner and his location, since this may change.
    self.owner_id = self.laptop.owner.id
    self.place_id = self.laptop.owner.place.id
  end

  def set_created_at
    self.created_at = Time.now
  end

  def register_notifications
    extended_data = { 
                      _("Id:") => self.id,
                      _("subject") => self.problem_type.name,
                      _("Location:") => self.place,
                      _("Reported by:") => self.person.getFullName
                    }
   NotificationsPool.register("problem_report", extended_data, place)
  end

  def getId
    self.id ? self.id.to_s : -1.to_s 
  end

  def getTechnicianIdDoc
    self.person_id ? self.person.getIdDoc : ""
  end

  def getProblemName
    self.problem_type_id ? self.problem_type.name : ""
  end

   def getLaptopSerialNumber
     self.laptop_id ? self.laptop.serial_number : ""
   end

   def getDate
     self.created_at ? self.created_at : ""
   end

   def getSolvedStatus
     self.solved ? true : false
   end

   def getSolvedDate
     self.solved_at ? self.solved_at.to_s : ""
   end

   def getComment
     self.comment ? self.comment : ""
   end

   def getParentPlaceName
     place_name = ""

     if self.place 
       if self.place.place 
         place_name = self.place.place
       else
         place_name = self.place
       end
     end

     place_name.to_s
   end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)
    scope = includes(:place => :ancestor_dependencies)
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    ProblemReport.with_scope(scope) do
      yield
    end
  end

end
