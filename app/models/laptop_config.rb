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
                                                                         
class LaptopConfig < ActiveRecord::Base

  def self.getColumnas()
    ret = Hash.new
    
    ret[:columnas] = 
      [ 
       {:name => "Id",:key => "id",:related_attribute => "id", :width => 50},
       {:name => "Descripcion",:key => "laptops.created_at",:related_attribute => "description", :width => 180},
       {:name => "Valor",:key => "laptops.serial_number",:related_attribute => "getValue()", :width => 120}
      ]

    ret[:columnas_visibles] = [false, true, true ]

    ret
  end


  def getValue()
    val = ""
    if self.key.match(/_id$/)
      model = eval(self.key.gsub(/_id/,"").camelize)
     
      if self.value
        obj = model.find(self.value)
        val = obj.name
      end
    else
      val = self.value
    end
    
    val
  end


end
