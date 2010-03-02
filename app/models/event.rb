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
                                                                         
class Event < ActiveRecord::Base
  belongs_to :event_type
  belongs_to :place

  def self.getColumnas()
    [ 
     {:name => _("Id"), :key => "events.id", :related_attribute => "id", :width => 50},
     {:name => _("Event"), :key => "event_types.name", :related_attribute => "getEventName()", :width => 160},
     {:name => _("Date"), :key => "events.created_at", :related_attribute => "getCreatedAt()", :width => 120},
     {:name => _("Reporter"), :key => "events.reporter_info", :related_attribute => "getReporterInfo", :width => 160},
     {:name => _("Information"), :key => "events.extended_info", :related_attribute => "getExtendedInfo", :width => 255},
     {:name => _("Location associated"), :key => "events.place_id", :related_attribute => "getPlaceName", :width => 255}
    ]
  end

  def self.register(event_type_tag, who_am_i, this_info, related_place_id)
    event_type = EventType.find_by_internal_tag(event_type_tag)
    if event_type
      event = Event.new
      event.event_type_id = event_type.id
      event.reporter_info = who_am_i
      event.extended_info = this_info
      event.place_id = related_place_id
      return true if event.save
    end
    false
  end

  def before_create
    self.created_at = Time.now
  end

  def getEventName
    self.event_type_id ? self.event_type.getName : ""
  end

  def getCreatedAt
    self.created_at ? self.created_at : ""
  end

  def getReporterInfo
    self.reporter_info ? self.reporter_info : ""
  end

  def getExtendedInfo
    self.extended_info ? self.extended_info : ""
  end

  def getHash
    self.extended_info ? JSON.parse(self.extended_info) : nil
  end

  def setHash(hash)
    self.extended_info = hash.to_json
  end

  def getPlaceName
    self.place_id ? self.place.getName : ""
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:place => :ancestor_dependencies]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    Event.with_scope(scope) do
      yield
    end

  end

end
