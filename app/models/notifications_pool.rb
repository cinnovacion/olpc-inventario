#     Copyright Paraguay Educa 2009, 2010
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
# Author: Martin Abente - mabente@paraguayeduca.org
#

class NotificationsPool < ActiveRecord::Base
  belongs_to :notification
  belongs_to :place

  attr_accessible :notification, :notification_Id
  attr_accessible :place, :place_id
  attr_accessible :sent, :extended_data

  validates_presence_of :notification_id, :message => N_("You must specify the notification.")
  validates_presence_of :place_id, :message => N_("You must specify the Location.")


  ####
  #
  #
  def self.register(notification_tag, extended_data, place)
    notification = Notification.find_by_internal_tag(notification_tag)
    raise _("The notification %s does not exist") % notification_tag if !notification
      
    NotificationsPool.create!({ :notification_id => notification.id, :extended_data => extended_data.to_json, :place_id => place.id })
  end


  ####
  #
  #
  def self.send_notifications
    cond = ["notifications_pools.sent = ?", false]
    NotificationsPool.find(:all, :conditions => cond).each { |pool_notification|

      notification = pool_notification.notification
      place = pool_notification.place
      extended_data = pool_notification.getExtendedData

      inc = [{:performs => {:place => :descendant_dependencies}}, {:notification_subscribers => :notification}]
      cond = ["place_dependencies.descendant_id = ? and notifications.id = ?", place.id, notification.id]
      destinations = Person.find(:all, :conditions => cond, :include => inc).map { |person| person.email }.compact.join(', ')

      if destinations.length == 0
        raise _("No one subscribed to the notification %s") % notification.name
      end
 
      Notifier.fire_notification(notification, extended_data, destinations).deliver
      pool_notification.sent = true
      pool_notification.save!
    }

    true
  end  

  def setExtendedData(hash = {})
    self.extended_data =  hash.to_json
  end


  def getExtendedData
    self.extended_data ? JSON.parse(self.extended_data) : {}
  end

end
