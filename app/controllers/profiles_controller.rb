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
                                                                       
class ProfilesController < SearchController
  def new

    if params[:id]
      profile = Profile.find(params[:id])
      @output["id"] = profile.id
    else
      profile = nil
    end
    
    @output["fields"] = []

    h = { "label" => _("Description"), "datatype" => "textfield" }.merge( profile ? {"value" => profile.description } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Internal Tag"), "datatype" => "textfield" }.merge( profile ? {"value" => profile.internal_tag } : {} )
    @output["fields"].push(h)

    tree = Controller.refreshMethodsTree
    profile.getMethodsTree(tree)  if profile
    h = { "label" => _("Permissions"), "datatype" => "permissions", "tree" => tree }
    @output["fields"].push(h)

    h = { "label" => _("Access level"), "datatype" => "textfield" }.merge( profile ? {"value" => profile.getAccessLevel } : {} )
    @output["fields"].push(h)
  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse
    attribs = Hash.new

    attribs[:description] = data_fields.pop
    attribs[:internal_tag] = data_fields.pop
    permissions = data_fields.pop
    attribs[:access_level] = data_fields.pop.to_i

    if datos["id"]
      profile = Profile.find(datos["id"])
      profile.register_update(attribs, permissions, current_user.person)
    else
      Profile.register(attribs, permissions, current_user.person)
    end

    @output["msg"] = datos["id"] ? _("Changes saved.") : _("Profile created.")  
  end

  def delete
    ids = JSON.parse(params[:payload])
    Profile.unregister(ids, current_user.person)
    @output["msg"] = _("Elements deleted.")
  end

end
