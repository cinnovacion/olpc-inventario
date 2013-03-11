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
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 

class SchoolInfosController < SearchController
  skip_filter :rpc_block, only: [ :lease_info, :list ]

  def new
    info = prepare_form
    form_label(_("Note"), _("Enter a value for either lease expiry date or lease duration, not both."))
    form_place_selector(info, "place_id", _("School"), width: 380, height: 120)
    form_textfield(info, "lease_duration", _("Lease duration (days)"))
    form_date(info, "lease_expiry", _("Lease expiry date"))
    form_textfield(info, "server_hostname", _("Hostname"))
    form_textfield(info, "wan_ip_address", _("IP address"))
    form_textfield(info, "wan_netmask", _("Netmask"))
    form_textfield(info, "wan_gateway", _("Gateway"))
  end

  def lease_info
    hostname = params[:hostname]
    info = SchoolInfo.includes(:place).find_by_server_hostname!(hostname)

    if info.lease_duration.nil?
      t = info.lease_expiry
    else
      t = Time.zone.now
      t += info.lease_duration * 3600 * 24

      # Avoid leases expiring at the weekend
      t += 3600 * 24 * 2 if t.saturday?
      t += 3600 * 24 if t.sunday?
    end

    # leases should expire at 6am
    expiry = Time.zone.local(t.year, t.month, t.day, 6, 0)
    expiry = expiry.utc.iso8601.gsub(":","").gsub("-","")

    render xml: {
      serials_uuids: info.place.laptops_uuids,
      expiry_date: expiry,
    }.to_xml
  end

  def list
    servers = SchoolInfo.where("server_hostname IS NOT NULL")
    render xml: servers.collect(&:server_hostname).to_xml
  end
end
