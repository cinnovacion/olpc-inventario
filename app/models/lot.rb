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
                                                                        
class Lot < ActiveRecord::Base
  has_many :section_details
  belongs_to :person

  attr_accessible :delivery_date, :delivered, :boxes_number
  attr_accessible :person, :person_id

  validates_presence_of :person_id, :message => N_("You must provide the responsible.")

  FIELDS = [
    {name: _("Id"), column: :id, width: 120},
    {name: _("Nbr of Boxes"), column: :boxes_number, width: 120},
    {name: _("Creation Date"), column: :created_at, width: 120},
    {name: _("Responsible"), association: :person, column: :lastname, attribute: :getResponsable, width: 255},
    {name: _("Delivered"), column: :delivered, width: 120},
    {name: _("Delivery Date"), column: :delivery_date, width: 120}
  ]

  def self.register(attribs, sections)

    Lot.transaction do
      #raise attribs.to_json
      lot = Lot.new(attribs)
      if lot.save!
        sections.each { |section_id|
          SectionDetail.register({ :lot_id => lot.id, :place_id => section_id})
        }
      end
    end

  end

  def self.register_die(lot)
    lot.section_details.each { |sectionDetail|
      SectionDetail.register_die(sectionDetail)
    }
    Lot.destroy(lot)
  end

  def register_update(attribs, sections)

    Lot.transaction do
      self.update_attributes(attribs)
      sections.each { |section_id|

        # We create all the new details added to the section list.
        if !SectionDetail.alreadyExists?(self.id, section_id)
          SectionDetail.register({ :lot_id => self.id, :place_id => section_id })
        end

      }

      # We delete all the old details that are not included anymore.
      self.section_details.each { |detail|
        SectionDetail.register_die(detail) if !sections.include?(detail.place_id)
      }

    end

  end

  def getBoxesNumber
    self.boxes_number ? self.boxes_number : ""
  end

  def getResponsable
    self.person_id ? self.person.getFullName : ""
  end

  def getDelivered
    self.delivered ? self.delivered == true ? "si" : "No" : "No"
  end

  def getDeliveryDate
    self.delivery_date ? self.delivery_date : ""
  end

  def getTitle
    self.id.to_s
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)
    scope = includes(:person => {:performs => {:place => :ancestor_dependencies}})
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    Lot.with_scope(scope) do
      yield
    end
  end

end
