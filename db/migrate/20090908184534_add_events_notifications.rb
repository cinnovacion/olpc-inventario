class AddEventsNotifications < ActiveRecord::Migration
  def self.up

    Notification.create({ :name => "Nodo Abajo", :description => "Un Nodo ha dejado de funcionar", :internal_tag => "node_down", :active => true})
    Notification.create({ :name => "Nodo Arriba", :description => "Un Nodo ha vuelto a funcionar", :internal_tag => "node_up", :active => true})

  end

  def self.down
  end
end
