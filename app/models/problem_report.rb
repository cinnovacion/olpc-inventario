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

  after_create :register_notifications
  before_validation :sync_laptop_details

   FIELDS = [ 
    {name: _("Id"), column: :id, width: 50},
    {name: _("Technician CI"), association: :person, column: :id_document, width: 120},
    {name: _("Type"), association: :problem_type, column: :name, width: 120},
    {name: _("Laptop"), association: :laptop, column: :serial_number, width: 120},
    {name: _("Place"), association: :place, column: :name, attribute: :getParentPlaceName, width: 120},
    {name: _("Report Date"), column: :created_at, width: 120},
    {name: _("Solved"), column: :solved, width: 120},
    {name: _("Solved at"), column: :solved_at, width: 120},
    {name: _("Comment"), column: :comment},
  ]

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
