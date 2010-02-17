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

                                                                          
class Profile < ActiveRecord::Base

  has_and_belongs_to_many :permissions
  has_many :performs
  has_many :people, :through => :performs, :source => :person

  validates_uniqueness_of :internal_tag, :message => "El tag debe ser unico"

  def self.getColumnas(vista = "")
    ret = Hash.new
    
    ret[:columnas] = [ 
                      {:name => "Id",:key => "profiles.id",:related_attribute => "id", :width => 50},
                      {:name => "Descripcion",:key => "profiles.description",:related_attribute => "getDescription()", :width => 140},
                      {:name => "Tag Interno",:key => "profiles.internal_tag",:related_attribute => "getInternalTag()", :width => 140},
                      {:name => "Nivel de Acceso",:key => "profiles.access_level",:related_attribute => "getAccessLevel()", :width => 140}
                     ]
    ret[:columnas_visibles] = [true,true,true]
    ret
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new

    case vista
    when ""
      ret["desc_col"] = 1
      ret["id_col"] = 0
    end

    ret
  end

  def getDescription()
    self.description ? self.description : "?"
  end

  def getInternalTag()
    self.internal_tag ? self.internal_tag : "?"
  end

  def getAccessLevel
    self.access_level ? self.access_level.to_s : "?"
  end

  def getMethodsTree(controller_tree)
    controller_tree.each { |controller|
      controller["methods"].each { |method|
        check = self.permissions.map { |p|
         (p.name == method["name"] and p.controller.name == controller["name"]) ? true : false
        }
        method["selected"] = true if check.include?(true)
      }
    }
    controller_tree
  end

  def self.register(attribs, permissions, register)

   raise "No tiene el suficiente nivel de acceso" if !(register.profile.access_level > attribs[:access_level].to_i)

    Profile.transaction do
      profile = Profile.new(attribs)
      if profile.save!
        permissions_ids = Controller.doMethodsTree(permissions)
        profile.permissions << Permission.find(permissions_ids)
      end
    end
  end

  def register_update(attribs, permissions, register)

   raise "No tiene el suficiente nivel de acceso" if !(register.profile.owns(self))

    Profile.transaction do
      if self.update_attributes!(attribs)
        self.permissions.delete(self.permissions)
        permissions_ids = Controller.doMethodsTree(permissions)
        self.permissions << Permission.find(permissions_ids)
      end
    end
  end

  def self.unregister(profiles_ids, unregister)

    to_destroy_profiles = Profile.find(:all, :conditions => ["profiles.id in (?)", profiles_ids ])
    to_destroy_profiles.each { |profile|
      raise "No tiene el suficiente nivel de acceso" if !(unregister.profile.owns(profile))
    }
    Profile.destroy(to_destroy_profiles)
  end

  def self.ids()
    ids = Profile.find(:all).map { |profile|
      profile.id
    }
  end

  ###
  #  Checks if the profiles determined by the internal_tag its in the ids list provided
  #
  def self.tagInList?(profiles_ids, profile_tag)
    cond = ["profiles.id in (?) and profiles.internal_tag = ?", profiles_ids, profile_tag]
    Profile.find(:first, :conditions => cond)
  end

  ###
  #  From a profiles objects list returns the highest level one.
  def self.highest(profiles)
    profiles.sort { |a,b| a.access_level < b.access_level ? -1 : 1 }.pop
  end

  ###
  #  A profile onws another then its access level is higher
  def owns(profile)
    return true if self.access_level > profile.access_level
  end

end