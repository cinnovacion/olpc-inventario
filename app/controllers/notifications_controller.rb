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
                                                                         
class NotificationsController < SearchController
  def new

    notification = nil
    if params[:id]
      notification = Notification.find(params[:id])
      @output["id"] = notification.id
    end

    @output["fields"] = []

    h = { "label" => _("Name"), "datatype" => "textfield" }.merge( notification ? {"value" => notification.name } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Description"), "datatype" => "textfield" }.merge( notification ? {"value" => notification.description } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Internal tag"), "datatype" => "textfield" }.merge( notification ? {"value" => notification.internal_tag } : {} )
    @output["fields"].push(h)

    options = buildBooleanSelectHash(notification ? notification.getActiveStatus() : true)
    h = { "label" => _("Active"), "datatype" => "combobox", "options" => options }
    @output["fields"].push(h)
  end

  def save

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = {}
    attribs[:name] = data_fields.pop
    attribs[:description] = data_fields.pop
    attribs[:internal_tag] = data_fields.pop
    attribs[:active] = data_fields.pop == 'N' ? false : true

    if datos["id"]
      notification = Notification.find_by_id(datos["id"])
      notification.update_attributes(attribs)
    else
      Notification.create(attribs)
    end

    @output["msg"] = datos["id"] ? _("Changes saved.") : _("Notification added.")
  end

  def delete
    ids = JSON.parse(params[:payload])
    Notification.destroy(ids)
    @output["msg"] = _("Elements deleted")
  end

end
