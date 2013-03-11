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
                                                                         
class ProblemType < ActiveRecord::Base
  has_many :problem_reports

  attr_accessible :description, :internal_tag, :name, :extended_info
  attr_accessible :is_hardware

  validates_uniqueness_of :internal_tag, :message => N_("The tag must be unique")

  FIELDS = [ 
    {name: _("Id"), column: :id, width: 50},
    {name: _("Name"), column: :name},
    {name: _("Description"), column: :description, width: 360},
    {name: _("Internal Tag"), column: :internal_tag},
  ]

  def to_s
    self.name.to_s
  end

  def getExtInfo
    self.extended_info ? self.extended_info : ""
  end
end
