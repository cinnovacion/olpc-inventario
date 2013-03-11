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
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 

class User < ActiveRecord::Base
  belongs_to :person

  attr_accessor :password
  attr_accessible :usuario, :password, :person_id, :person

  validates :usuario, presence: true, uniqueness: true
  validates :password, allow_blank: true, length: { minimum: 5, too_short: N_("Must be at least 5 characters") }
  validates :clave, presence: true

  # We presume the password comes hashed (with SHA1) from the client side. 
  #
  # FIXME: we should check if it _actually_ is hashed, otherwise hash it ourselves. 
  #        Server-side code should never trust the client!
  before_validation { self.clave = self.password if !self.password.blank? }

  FIELDS = [ 
    {name: _("ID"), column: :id, width: 50},
    {name: _("Username"), column: :usuario, width: 90},
    {name: _("Name"), association: :person, column: :lastname, attribute: :person, width: 250}
  ]

  def self.getChooseButtonColumns
    { desc_col: 1, id_col: 0 }
  end

  # Root places where the user has access
  def root_places
    person = self.person
    query = Place.includes(:performs)
    query.where('performs.person_id' => person.id, 'performs.profile_id' => person.profile.id)
  end

  # Again, we presume the password comes hashed (with SHA1) from the client side. 
  def self.login(name,password)
    User.where(usuario: name, clave: password).first
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
end
