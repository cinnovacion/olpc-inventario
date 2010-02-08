class AddIsDeliveryToMovementTypes < ActiveRecord::Migration
  def self.up
    add_column :movement_types, :is_delivery, :boolean, :default => true

    not_delivery_movement_tags = [ 
                                   "reparacion",
                                   "devolucion_problema_tecnico_entrega",
                                   "devolucion", 
                                   "verificacion_finalizada",
                                   "reparacion_finalizada",
                                   "transfer"
                                 ]

    not_delivery_movements = MovementType.find(:all, :conditions => ["movement_types.internal_tag in (?)",not_delivery_movement_tags])
    not_delivery_movements.each { |movement|
      movement.is_delivery = false
      movement.save
    }

  end

  def self.down
    remove_column :movement_types, :is_delivery
  end

end
