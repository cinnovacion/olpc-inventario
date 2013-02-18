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

require 'fecha'

class NotificationSubscribersController < SearchController
  def initialize
    super(:includes => [:notification,:person])
  end

  def new
    @output["fields"] = []

    p = nil
    if params[:id]
      p = NotificationSubscriber.find params[:id]
      @output["id"] = p.id
    end

    opts = []
    if p
      opts = buildSelectHash2(Notification, p.notification_id, "name",false,["notifications.id = ?", p.notification_id])
    end
    h = { "label" => _("Notification"), "datatype" => "select", "options" => opts, "option" => "notifications" }
    @output["fields"].push(h)

    opts = []
    if p 
      opts = buildSelectHash2(Person, p.person_id, "getFullName()",false,["people.id = ?", p.person_id])
    end
    h = { "label" => _("Suscriber"),"datatype" => "select","options" => opts, "option" => "people" }
    @output["fields"].push(h)

  end

  def save
    datos = JSON.parse(params[:payload])

    attribs = Hash.new
    attribs[:notification_id] = datos["fields"][0]
    attribs[:person_id] = datos["fields"][1]
    attribs[:created_at] = Fecha::getFecha()

    save_object(NotificationSubscriber,datos["id"],attribs)
    @output["msg"] = _("Changes saved.")
  end

  def delete
    ids = JSON.parse(params[:payload])
    NotificationSubscriber.transaction do
      NotificationSubscriber.destroy(ids)
    end
    @output["msg"] = "Suscription deleted."
  end

end
