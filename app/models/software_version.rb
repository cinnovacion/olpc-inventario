#     Copyright Daniel Drake 2012
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

class SoftwareVersion < ActiveRecord::Base
  belongs_to :model

  validates :name, :presence => true
  validates :vhash, :uniqueness => true, :allow_nil => true, :format => { :with => /[a-z0-9]{64}/ }

  def self.getColumnas(vista = "")
    [ 
     {:name => _("Id"), :key => "software_versions.id", :related_attribute => "id", :width => 50},
     {:name => _("Name"), :key => "software_versions.name", :related_attribute => "name", :width => 100},
     {:name => _("Laptop model"), :key => "models.name", :related_attribute => "model", :width => 100},
     {:name => _("Description"), :key => "software_versions.description", :related_attribute => "description", :width => 200},
     {:name => _("Hash"),:key => "software_versions.vhash", :related_attribute => "vhash", :width => 100},
    ]
  end

  def to_s
    name
  end
end
