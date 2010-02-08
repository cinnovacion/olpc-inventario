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
                                                                       
class Notification < ActiveRecord::Base

  has_many :notification_subscribers

  validates_uniqueness_of :internal_tag
  validates_uniqueness_of :name

  ##
  # Listado de columnas.
  def self.getColumnas()
    ret = Hash.new 
    ret[:columnas] = [
                      {:name => "Id",
                       :key => "notifications.id",
                       :related_attribute => "id",
                       :width => 50
                      },
                      {:name => "Nombre",
                       :key => "notifications.name",
                       :related_attribute => "getName()",
                       :width => 100
                      },
                      {:name => "Descripcion",
                       :key => "notifications.description",
                       :related_attribute => "getDescription()",
                       :width => 255
                      },
                      {:name => "Activo",
                       :key => "notifications.description",
                       :related_attribute => "getActiveStatus()",
                       :width => 5
                      }
                     ]


    ret[:columnas_visibles] = [false,true,true,true]
    ret
  end

  ##
  # Para que se puede usar los select
  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new

    case vista
    when ""
      ret["desc_col"] = 1
      ret["id_col"] = 0
    end

    ret
  end

  ##
  # Nombre de la notificacion.
  def getName()
    self.name ? self.name : ""
  end

  ##
  # Descripcion de la notificacion probablemente el mensaje.
  def getDescription()
    self.description ? self.description : ""
  end

  def getInternalTag()
    self.internal_tag ? self.internal_tag : ""
  end

  ##
  # Activo o no activo
  def getActiveStatus()
    self.active ? true : false
  end

end
