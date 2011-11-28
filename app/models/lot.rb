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

  validates_presence_of :person_id, :message => N_("You must provide the responsible.")

  def self.getColumnas()
    [ 
     {:name => _("Id"),:key => "lots.id",:related_attribute => "id", :width => 120},
     {:name => _("Nbr of Boxes"),:key => "lots.boxes_number",:related_attribute => "getBoxesNumber()", :width => 120},
     {:name => _("Creation Date"),:key => "lots.created_at",:related_attribute => "getCreatedAt()", :width => 120},
     {:name => _("Responsible"),:key => "people.name",:related_attribute => "getResponsable()", :width => 255},
     {:name => _("Delivered"),:key => "lots.delivered",:related_attribute => "getDelivered()", :width => 120},
     {:name => _("Delivery Date"),:key => "lots.delivery_date",:related_attribute => "getDeliveryDate()", :width => 120}
    ]
   end

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

  def before_create
    self.created_at = Time.now
  end

  def getBoxesNumber
    self.boxes_number ? self.boxes_number : ""
  end

  def getCreatedAt
    self.created_at ? self.created_at : ""
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

    find_include = [:person => {:performs => {:place => :ancestor_dependencies}}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    Lot.with_scope(scope) do
      yield
    end

  end

end
