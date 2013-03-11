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
                                                                        
class PartType < ActiveRecord::Base
  has_many :parts

  attr_accessible :description, :internal_tag, :cost

  validates_uniqueness_of :internal_tag, :message => N_("The tag must be unique")

  FIELDS = [ 
    {name: _("Id"), column: :id, width: 50},
    {name: _("Description"), column: :description, width: 250},
    {name: _("Cost"), column: :cost},
    {name: _("Internal Tag"), column: :internal_tag, width: 250},
  ]

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new
    ret["desc_col"] = 1
    ret["id_col"] = 0
    ret
  end

  def getCost()
    self.cost ? self.cost.to_s : ""
  end

end
