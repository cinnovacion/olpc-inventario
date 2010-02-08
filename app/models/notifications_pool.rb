class NotificationsPool < ActiveRecord::Base

  belongs_to :notification
  belongs_to :place

  validates_presence_of :notification_id, :message => "Debe especificar la Notification."
  validates_presence_of :place_id, :message => "Debe especificar la Localidad."

  def self.register(notification_tag, extended_data, place)

    notification = Notification.find_by_internal_tag(notification_tag)
    raise "No existe notificacion #{notification_tag}" if !notification
      
    NotificationsPool.create!({ :notification_id => notification.id, :extended_data => extended_data.to_json, :place_id => place.id })
  end

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
        raise " No hay nadie suscripto a la notificacion #{notification.name} "
      end
 
      Notifier.deliver_fire_notification(notification, extended_data, destinations)
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
