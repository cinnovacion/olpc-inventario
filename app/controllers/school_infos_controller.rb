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
                                                                          
class SchoolInfosController < SearchController
  attr_accessor :include_str

  def initialize
    super 
    @include_str = []
  end

  def search
    do_search(SchoolInfo,{ :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(SchoolInfo)
    do_search(SchoolInfo,{ :include => @include_str })
  end

  def new
    
    if params[:id]
      schoolInfo = SchoolInfo.find(params[:id])
      @output["id"] = schoolInfo.id
    else
      schoolInfo = nil
    end
    
    @output["fields"] = []

    h = { "label" => _("Note"), "datatype" => "label", :text => _("Enter a value for either lease expiry date or lease duration, not both.") }
    @output["fields"].push(h)

    h = { "label" => _("School"), "datatype" => "hierarchy_on_demand", "options" => { "width" => 380, "height" => 120 }}
    h.merge!( schoolInfo && schoolInfo.place ? {"dataHash" => schoolInfo.place.getElementsHash } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Lease duration (days)"), "datatype" => "textfield" }.merge( schoolInfo ? {"value" => schoolInfo.getDuration.to_s } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Lease expiry date"), "datatype" => "date" }.merge( schoolInfo ? {"value" => schoolInfo.getExpiry } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Hostname"), "datatype" => "textfield" }.merge( schoolInfo ? {"value" => schoolInfo.getHostname } : {} )
    @output["fields"].push(h)

    h = { "label" => _("IP address"), "datatype" => "textfield" }.merge( schoolInfo ? {"value" => schoolInfo.getIpAddress } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Netmask"), "datatype" => "textfield" }.merge( schoolInfo ? {"value" => schoolInfo.getNetmask } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Gateway"), "datatype" => "textfield" }.merge( schoolInfo ? {"value" => schoolInfo.getGateway } : {} )
    @output["fields"].push(h)

  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:place_id] = data_fields.pop
    attribs[:lease_duration] = data_fields.pop
    attribs[:lease_expiry] = data_fields.pop
    attribs[:server_hostname] = data_fields.pop
    attribs[:wan_ip_address] = data_fields.pop
    attribs[:wan_netmask] = data_fields.pop
    attribs[:wan_gateway] = data_fields.pop

    if datos["id"]
      schoolInfo = SchoolInfo.find_by_id(datos["id"])
      schoolInfo.update_attributes!(attribs)
    else
      SchoolInfo.create!(attribs)
    end

    @output["msg"] = datos["id"] ? _("Changes saved.") : _("Information added.")  
  end

  def delete
    ids = JSON.parse(params[:payload])
    SchoolInfo.destroy(ids)
    @output["msg"] = "Elements deleted."
  end

end
