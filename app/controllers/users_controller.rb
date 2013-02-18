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
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 

class UsersController < SearchController
  def initialize
    super(:includes => :person)
  end

  def new
    user = prepare_form

    form_textfield(user, "usuario", _("User"))
    form_password(user, "password", _("Password"))
    form_password(user, "password2", _("Re-type password"))

    id = user ? user.person_id : -1
    people = buildSelectHash2(Person, id, "getFullName()", false, ["people.id = ?", id])
    form_select("person_id", "people", _("Person"), people)
  end

  def save
    data = JSON.parse(params[:payload])
    attribs = data["fields"]

    raise _("Passwords don't match.") if attribs["password"] != attribs["password2"]
    attribs.delete("password2")

    if data["id"]
      user = User.find(data["id"])
      if !(current_user.person.owns(user.person) || current_user == user)
        raise _("You do not have the sufficient level of access")
      end

      user.update_attributes!(attribs)
    else
      person = Person.find(attribs["person_id"])
      if !current_user.person.owns(person)
        raise _("You do not have enough access level.")
      end
      User.create!(attribs)
    end

    @output["msg"] = data["id"] ? _("Changes saved.") : _("User added.")
  end

  def delete
    current_person = current_user.person
    ids = JSON.parse(params[:payload])
    users = User.find_all_by_id(ids)
    users.each { |user|
      raise _("You do not have the sufficient level of access") if !(current_person.owns(user.person))
    }
    User.destroy(ids)
    @output["msg"] = "Elements deleted."
  end
end
