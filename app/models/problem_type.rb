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

  validates_uniqueness_of :internal_tag, :message => "El tag debe ser unico"

  def self.getColumnas()
    [ 
     {:name => "Id", :key => "problem_types.id", :related_attribute => "id", :width => 50},
     {:name => "Nombre", :key => "problem_types.name", :related_attribute => "getName", :width => 100},
     {:name => "Descripcion", :key => "problem_types.description", :related_attribute => "getDescription()", :width => 360},
     {:name => "Tag Interno",:key => "problem_types.internal_tag",:related_attribute => "getInternalTag()", :width => 100}
    ]
  end

  def getName
    self.name ? self.name : ""
  end

  def getDescription()
    self.description
  end

  def getExtInfo
    self.extended_info ? self.extended_info : ""
  end

  def getInternalTag()
    self.internal_tag
  end

end
