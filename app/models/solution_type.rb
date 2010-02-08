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
                                                                        
class SolutionType < ActiveRecord::Base
  has_many :problem_solutions
  belongs_to :part_type

  validates_uniqueness_of :internal_tag, :message => "El tag debe ser unico"

  def self.getColumnas()
    [ 
      {:name => "Id", :key => "solution_types.id", :related_attribute => "id", :width => 50},
      {:name => "Nombre", :key => "solution_types.name", :related_attribute => "getName()", :width => 200},
      {:name => "Descripcion", :key => "solution_types.description", :related_attribute => "getDescription()", :width => 360},
      {:name => "Tag", :key => "solution_types.name", :related_attribute => "getInternalTag()", :width => 200},
      {:name => "Requiere Parte", :key => "solution_types.part_type_id", :related_attribute => "getPartType()", :width => 200}
    ]
  end

  def getName
    self.name ? self.name : ""
  end

  def getDescription
    self.description ? self.description : ""
  end

  def getExtInfo
    self.extended_info ? self.extended_info : ""
  end

  def getInternalTag
    self.internal_tag ? self.internal_tag : ""
  end

  def getPartType
    self.part_type_id ? self.part_type.getDescription : "No"
  end

  def requirePart
    self.part_type_id ? true : false
  end

end
