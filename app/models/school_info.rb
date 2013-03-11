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

class SchoolInfo < ActiveRecord::Base
  belongs_to :place
  validate :expiry_or_duration
  validates :place, presence: true

  attr_accessible :server_hostname, :lease_duration, :lease_expiry
  attr_accessible :wan_ip_address, :wan_netmask, :wan_gateway, :place_id

  FIELDS = [
    {name: _("Id"), column: :id, width: 50},
    {name: _("Place"), association: :place, column: :description, attribute: :place},
    {name: _("Activation expiry"), column: :lease_duration, attribute: :lease_info},
    {name: _("Hostname"), column: :server_hostname},
    {name: _("Address"), column: :wan_ip_address},
    {name: _("Netmask"), column: :wan_netmask},
    {name: _("Gateway"), column: :wan_gateway},
  ]

  # accessor override
  def lease_duration
    if self[:lease_duration] && self[:lease_duration] != 0
      return self[:lease_duration]
    end

    if !self.lease_expiry
      # by default leases endure 3 weeks
      return (7*3)
    end
  end

  def lease_info
    duration = self.lease_duration
    return self.lease_expiry if duration.nil?
    return n_("%{num} day", "%{num} days", duration) % { num: duration }
  end

  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)
    scope = includes(place: :ancestor_dependencies)
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    SchoolInfo.with_scope(scope) do
      yield
    end
  end

 private
  def expiry_or_duration
    if lease_duration and lease_expiry
      errors.add(:lease_duration, _("Lease duration or expiry must be set, not both."))
    end
  end

end
