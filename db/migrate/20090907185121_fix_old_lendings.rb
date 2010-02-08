class FixOldLendings < ActiveRecord::Migration
  def self.up

    MovementDetail.transaction do

      devices_classes = [Laptop, Battery, Charger]

      devices_classes.each { |device_class|

        device_class.all.each { |device|

          device_class_str = device.class.to_s.downcase

          inc = [{:movement => :movement_type}]
          cond = ["movement_details.#{device_class_str}_id = ?", device.id]
          details = MovementDetail.find(:all, :conditions => cond, :include => inc, :order => "movements.id ASC")

          last_lending = nil
          details.each { |detail|
       
            if last_lending && detail
         
              last_lending.returned = true
              last_lending.save! 
            end 

            last_lending = detail if detail.movement.movement_type.internal_tag == "prestamo"

          }
        }
      }

    end

  end

  def self.down
  end
end
