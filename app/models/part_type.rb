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

  validates_uniqueness_of :internal_tag, :message => "El tag debe ser unico"

  def self.getColumnas()
    [ 
     {:name => "Id",:key => "part_types.id",:related_attribute => "id", :width => 50},
     {:name => "Descripcion",:key => "part_types.description",:related_attribute => "getDescription()", :width => 250},
     {:name => "Costo", :key => "part_types.cost", :related_attribute => "getCost()", :width => 100},
     {:name => "Tag Interno",:key => "part_types.internal_tag",:related_attribute => "getInternalTag()", :width => 250}
    ]
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new
    ret["desc_col"] = 1
    ret["id_col"] = 0
    ret
  end

  def getDescription()
    self.description ? self.description : ""
  end

  def getInternalTag()
    self.internal_tag ? self.internal_tag : ""
  end

  def getCost()
    self.cost ? self.cost.to_s : ""
  end

end