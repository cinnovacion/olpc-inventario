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
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #
                                                                        
class Model < ActiveRecord::Base
  has_many :laptops

  validates_presence_of :name
  validates_presence_of :description

  def self.getColumnas()
    [ 
     {:name => "Id",:key => "models.id",:related_attribute => "id", :width => 50},
     {:name => "Creacion",:key => "models.created_at",:related_attribute => "created_at.to_s", :width => 120},
     {:name => "Nombre",:key => "models.name",:related_attribute => "getName()", :width => 200},
     {:name => "Descripcion",:key => "models.description",:related_attribute => "getDescription()", :width => 400}
    ]
  end

  def before_save
    self.created_at = Time.now
  end


  ###
  #
  #
  def getName()
    self.name ? self.name : ""
  end
  
  ###  
  #
  #
  def getDescription()
    self.description ? self.description : ""
  end



end
