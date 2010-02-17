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

# # #
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #
                                                                   
require "digest/sha1"

class User < ActiveRecord::Base

  belongs_to :person

  # Atributos
  attr_accessor :password
  attr_accessible :usuario, :password, :person_id

  # Validaciones
  validates_uniqueness_of :usuario, :if => :existe_usuario
  validates_presence_of :password, :if => :existe_passwd
  validates_length_of :usuario, :allow_nil => true, :minimum => 5, :too_short => "Debe tener al menos %d caracteres"
  validates_length_of :password, :allow_nil => true, :minimum => 5, :too_short => "Debe tener al menos %d caracteres"

  
  ##
  # Listado
  #
  def self.getColumnas
    [ 
     {:name => "Codigo",:key => "users.id",:related_attribute => "id", :width => 50},
     {:name => "Nombre de Usuario",:key => "users.usuario",:related_attribute => "usuario", :width => 90},
     {:name => "Nombre de Persona",:key => "people.name",:related_attribute => "getPersonName()", :width => 250}
    ]
  end

  def self.class_name
    "User"
  end


  def self.getChooseButtonColumns
    ret = Hash.new
    ret["desc_col"] = 1
    ret["id_col"] = 0
    ret
  end

  ###
  # To add extra security control, we take over
  # the users creation.
  def self.register(attribs, register)

    users_person = Person.find_by_id(attribs[:person_id])
    raise "Usted no posee el suficiente nivel de acceso." if !(register.owns(users_person))
    User.create!(attribs)

  end

  def register_update(attribs, register)

    new_users_person = Person.find_by_id(attribs[:person_id])
    raise "Usted no posee el suficiente nivel de acceso." if !( register.owns(self.person) || register == new_users_person )
    self.update_attributes(attribs)

  end

  def self.unregister(users_ids, unregister)

    to_be_destroy_users = User.find(:all, :conditions => ["users.id in (?)", users_ids])
    to_be_destroy_users.each { |user|
       raise "Usted no posee el suficiente nivel de accesso" if !(unregister.owns(user.person))
    }
    User.destroy(to_be_destroy_users)

  end

  ###
  # Nombre de usuario
  #
  def getDescripcion()
    self.usuario
  end

  def getPersonName()
    self.person ? self.person.getFullName() : ""
  end

  def before_create
    if self.password and self.password != ""
      #self.clave = User.hash_password(self.password)
      self.clave = self.password
    end
  end

  def after_create
    @password = nil
  end
  
  def before_update
    if self.password and self.password != ""
      #self.clave = User.hash_password(self.password)
      self.clave = self.password
    end
  end

  def after_update
    @password = nil
  end
  
  def self.hash_password(password)
    Digest::SHA1.hexdigest(password)
  end

  def self.login(name,password)
    #hashed_password = hash_password(password || "")
    find(:first, :conditions => ["usuario = ? and clave = ?", name, password])
  end

  def autenticar
    User.login(self.usuario, self.password)
  end

  def hasProfiles?(profiles_tags)

    inc = [:performs => :profile]
    cond = ["performs.person_id =? and profiles.internal_tag in (?)", self.person.id, profiles_tags]
    return true if Profile.find(:first, :conditions => cond, :include => inc)
    false
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:person => {:performs => {:place => :ancestor_dependencies}}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    User.with_scope(scope) do
      yield
    end

  end

  private
  def existe_usuario
    self.usuario ? true : false
  end

  def existe_passwd
    ret = false
    if existe_usuario
      #or (self.clave and self.clave != "")
      if not self.clave 
        ret = true
      end
    end
    ret
  end


end