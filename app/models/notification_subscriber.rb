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
                                                                        
class NotificationSubscriber < ActiveRecord::Base

  belongs_to :person
  belongs_to :notification

  validates_presence_of :person_id, :message => N_("You must provide the subscriber.")
  validates_presence_of :notification_id, :message => N_("You must provide the Notification.")

  before_save :validate_person

  def self.getColumnas()
    ret = Hash.new 
    ret[:columnas] = [
                      {:name => _("Id"),
                       :key => "notification_subscribers.id",
                       :related_attribute => "id",
                       :width => 50
                      },
                      {:name => _("Notification"),
                       :key => "notifications.name",
                       :related_attribute => "getNotificationName()",
                       :width => 100
                      },
                      {:name => _("Subscriber"),
                       :key => "people.name",
                       :related_attribute => "getSubscriberName()",
                       :width => 100
                      },
                      {:name => _("Date of Subscription"),
                       :key => "notification_subscribers.created_at.name",
                       :related_attribute => "getDate()",
                       :width => 120
                      }
                     ]


    ret[:columnas_visibles] = [false,true,true,true]
    ret
  end

  def validate_person()
    if !self.person.isEmailValid?
      person_name = self.person.getFullName()
      error_msg =  _("%s does not have a valid email address. It can not be signed") % person_name
      raise error_msg
    end
  end

  ##
  # Se Obtiene el nombre de la notificacion.
  def getNotificationName()
    self.notification.getName()
  end

  ##
  # Se obtiene el nombre del suscriptor.
  def getSubscriberName()
    self.person.getFullName()
  end

  ##
  # Se obtiene la fecha de la suscripcion
  def getDate()
    self.created_at.to_s
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)
    scope = includes(:person => {:performs => {:place => :ancestor_dependencies}})
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    NotificationSubscriber.with_scope(scope) do
      yield
    end
  end

end
