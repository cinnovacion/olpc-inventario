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

  attr_accessor :password
  attr_accessible :usuario, :password, :person_id

  validates_uniqueness_of :usuario, :if => :user_exists?
  validates_presence_of :password, :if => :password_exists?
  validates_length_of :usuario, :allow_nil => true, :minimum => 5, :too_short => N_("Must be at least %d characters")
  validates_length_of :password, :allow_nil => true, :minimum => 5, :too_short => N_("Must be at least %d characters")

  before_create :ensure_clave
  before_update :ensure_clave
  after_create :set_nil_password
  after_update :set_nil_password

  ##
  # Listing
  #
  def self.getColumnas
    [ 
     {:name => _("ID"),:key => "users.id",:related_attribute => "id", :width => 50},
     {:name => _("Username"),:key => "users.usuario",:related_attribute => "usuario", :width => 90},
     {:name => _("Name"),:key => "people.name",:related_attribute => "getPersonName()", :width => 250}
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
    raise _("You do not have enough access level.") if !(register.owns(users_person))
    User.create!(attribs)
  end

  ###
  # Update user's data.
  # 
  def register_update(attribs, register)
    new_users_person = Person.find_by_id(attribs[:person_id])
    raise _("You do not have the sufficient level of access") if !( register.owns(self.person) || register == new_users_person )
    self.update_attributes(attribs)
  end


  ###
  # Delete user.  
  #
  def self.unregister(users_ids, unregister)
    to_be_destroy_users = User.find_all_by_id(user_ids)
    to_be_destroy_users.each { |user|
       raise _("You do not have the sufficient level of access") if !(unregister.owns(user.person))
    }
    User.destroy(to_be_destroy_users)
  end

  ###
  # User's name. 
  #
  def getDescripcion()
    self.usuario
  end

  def getPersonName()
    self.person ? self.person.getFullName() : ""
  end

  ####
  # We presume the password comes hashed (with SHA1) from the client side. 
  #
  # FIXME: we should check if it _actually_ is hashed, otherwise hash it ourselves. 
  #        Server-side code should never trust the client!
  def ensure_clave
    if self.password and self.password != ""
      self.clave = self.password
    end
  end

  def set_nil_password
    @password = nil
  end
  
  def self.hash_password(password)
    Digest::SHA1.hexdigest(password)
  end

  ####
  # Again, we presume the password comes hashed (with SHA1) from the client side. 
  #
  def self.login(name,password)
    User.where(:usuario => name, :clave => password).first
  end

  def authenticate
    User.login(self.usuario, self.password)
  end

  def hasProfiles?(profiles_tags)
    profiles = Profile.includes(:performs => :profile)
    profiles = profiles.where("performs.person_id = ? and profiles.internal_tag in (?)", self.person.id, profiles_tags)
    return true if profiles.first
    false
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)
    scope = includes(:person => {:performs => {:place => :ancestor_dependencies}})
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    User.with_scope(scope) do
      yield
    end
  end

  private
  def user_exists?
    self.usuario ? true : false
  end

  def password_exists?
    ret = false
    if user_exists?
      if not self.clave 
        ret = true
      end
    end
    ret
  end


end
