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
                                                                          
class UsersController < SearchController
  attr_accessor :include_str

  def initialize
    super
    @include_str = [:person]
  end

  def search
    do_search(User, {:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(User)
    do_search(User, {:include => @include_str })
  end

  def new
    if params[:id]
      user = User.find(params[:id])
      @output["id"] = user.id
    else
      user = nil
    end

    @output["fields"] = []

    h = { "label" => _("User"), "datatype" => "textfield" }.merge( user ? {"value" => user.usuario } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Password"), "datatype" => "passwordfield" }
    @output["fields"].push(h)

    h = { "label" => _("Re-type Password"), "datatype" => "passwordfield" }
    @output["fields"].push(h)

    id = user ? user.person_id : -1
    people = buildSelectHash2(Person, id, "getFullName()", false, ["people.id = ?", id])
    h = { "label" => _("Person"), "datatype" => "select", :option => "personas" }.merge( user ? {"options" => people} : {} )
    @output["fields"].push(h)
  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse
    attribs = Hash.new

    attribs[:usuario] = data_fields.pop
    attribs[:password] = data_fields.pop
    rep = data_fields.pop
    attribs[:person_id] = data_fields.pop

    raise _("Passwords don't match.") if attribs[:password] != rep

    if datos["id"]
      user = User.find_by_id(datos["id"])
      user.register_update(attribs, current_user.person)
    else
      User.register(attribs, current_user.person)
    end

    @output["msg"] = datos["id"] ? _("Changes saved.") : _("User added.")
  end

  def delete
    ids = JSON.parse(params[:payload])
    User.unregister(ids, current_user.person)
    @output["msg"] = _("Elements deleted.")
  end

end
