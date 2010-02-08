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
                                                                         
class SchoolInfo < ActiveRecord::Base
  belongs_to :place

  def self.getColumnas(vista = "")
    ret = Hash.new

    case vista
      when /place_\d/
        place_id = vista.split('_')[1]
        ret[:conditions] = ["school_infos.place_id = ?",place_id]
    end

    ret[:columnas] = [ 
     {:name => "Id", :key => "school_infos.id", :related_attribute => "id", :width => 50},
     {:name => "Place", :key => "places.description", :related_attribute => "getPlaceDescription", :width => 100},
     {:name => "Duration",:key => "school_infos.lease_duration", :related_attribute => "getDuration()", :width => 100},
     {:name => "Hostname", :key => "school_infos.server_hostname", :related_attribute => "getHostname()", :width => 100},
     {:name => "Address", :key => "school_infos.wan_ip_address", :related_attribute => "getIpAddress()", :width => 100},
     {:name => "Netmask", :key => "school_infos.wan_netmask", :related_attribute => "getNetmask()", :width => 100},
     {:name => "Gateway", :key => "school_infos.wan_gateway", :related_attribute => "getGateway()", :width => 100}
    ]

    ret
  end

  def getPlaceDescription
    self.place_id ? self.place.getDescription : ""
  end

  # by default leases endure 3 weeks
  def getDuration
    self.lease_duration && self.lease_duration.to_i != 0 ? self.lease_duration.to_i : (3600*24*7*3)
  end

  def getHostname
    self.server_hostname ? self.server_hostname : ""
  end

  def getIpAddress
    self.wan_ip_address ? self.wan_ip_address : ""
  end

  def getNetmask
    self.wan_netmask ? self.wan_netmask : ""
  end

  def getGateway
    self.wan_gateway ? self.wan_gateway : ""
  end 

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [{:place => :ancestor_dependencies}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    SchoolInfo.with_scope(scope) do
      yield
    end

  end

end
