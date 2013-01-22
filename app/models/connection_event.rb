# Copyright One Laptop per Child 2013
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

class ConnectionEvent < ActiveRecord::Base
  belongs_to :laptop, inverse_of: :connection_events
  attr_accessible :ip_address, :vhash, :free_space, :stolen, :connected_at

  validates :laptop, :presence => true
  validates :vhash, :allow_nil => true, :format => { :with => /[a-z0-9]{64}/ }
  before_save { self.connected_at = Time.now if self.connected_at.nil? }

  def self.getColumnas(vista = "")
    [
     {name: _("Id"), key: "connection_events.id", related_attribute: "id"},
     {name: _("Laptop"), key: "laptops.serial_number", related_attribute: "laptop.serial_number"},
     {name: _("Connected at"), key: "connection_events.connected_at", related_attribute: "connected_at", width: 150},
     {name: _("IP address"), key: "connection_events.ip_address", related_attribute: "ip_address"},
     {name: _("Software version"), key: "software_versions.name", related_attribute: "software_version"},
     {name: _("Software version hash"), key: "connection_events.vhash", related_attribute: "vhash"},
     {name: _("Free disk space"), key: "connection_events.free_space", :related_attribute => "free_space"},
    ]
  end

  def software_version
    SoftwareVersion.find_by_vhash(vhash)
  end
end
