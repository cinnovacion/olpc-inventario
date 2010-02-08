# This migration creates boxes that yet don't exist but
# whose serial number has been registered along with
# the laptops it contains. It also generates a association
# between laptops and the box that contains them.
#
#

class CreateBoxesFromLaptops < ActiveRecord::Migration

  def self.up

    #
    # Tomamos valores x default.. 
    #
    c = LaptopConfig.find_by_key("shipment_id")
    if !c.value || c.value.to_i <= 0
      raise "Debe estar configurado el valor por defecto para el cargamento"
    end
    shipment_id = c.value.to_i

    c = LaptopConfig.find_by_key("place_id")
    if !c.value || c.value.to_i <= 0
      raise "Debe estar configurado el valor por defecto para saber en que localidad estan las cajas"
    end
    place_id = c.value.to_i

    #
    # Creamos cajas..
    #
    Laptop.find(:all).each { |lap|
      if lap.box_serial_number && !lap.box_serial_number.to_s.match(/^ *$/)
        boxObj = Box.find_by_serial_number(lap.box_serial_number)
        if !boxObj
          h = Hash.new
          h[:shipment_id] = shipment_id
          h[:place_id]  = place_id
          h[:serial_number] = lap.box_serial_number
          boxObj = Box.create!(h)
        end

        lap.box_id = boxObj.id
        lap.save!
      end
    }

  end

  def self.down
  end
end
