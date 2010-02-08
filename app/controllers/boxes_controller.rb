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
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #
                                                                         
class BoxesController < SearchController
  attr_accessor :include_str

  def initialize
    super 
    @include_str = [:shipment, :laptops, :batteries, :chargers]
  end

  def search
    do_search(Box,{ :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Box)
    do_search(Box,{ :include => @include_str })
  end


  def new
    @output["fields"] = []

    # check that we have default values configurated
    load_default_values()

    if params[:id]
      p = Box.find(params[:id])
      @output["id"] = p.id
    end

    h = { "label" => "Nro. Serie Caja","datatype" => "textfield" }.merge( p ? {"value" => p.serial_number } : {} )
    @output["fields"].push(h)

    5.times do |i|
      num_laptop = i + 1
      h = { "label" => "Nro. Serie Laptop ##{num_laptop}","datatype" => "textfield" }
      @output["fields"].push(h)
    end

  end

  def save
    load_default_values()

    datos = JSON.parse(params[:payload])

    if datos["ids"]
      raise "Solo se puede modificar una caja a la vez"
    end

    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:serial_number] = getAbmFormValue(data_fields.pop)
    attribs[:shipment_id] = @shipment_arrival_id
    attribs[:place_id] = @place_id

    laptops_serial_numbers = Array.new
    5.times do |i|
      v = data_fields.pop
      laptops_serial_numbers.push(v) if v && !v.to_s.match(/^ *$/)
    end

    # create the box and the laptops
    Box.transaction do 

      boxObj = nil
      if datos["id"]
        boxObj = Box.find datos["id"]
        boxObj.update_attributes!(attribs)
    
        # destroy existing laptops (and recreate them according to new data)
        #  an exception will jump here if associated operations exists,
        #  advice user that he should modify data from the other screen
        boxObj.laptops.each { |l| l.destroy } 
        
      else
        boxObj = Box.create!(attribs)
      end

      laptops_serial_numbers.each { |snum|
        l = Laptop.new
        l.build_version = @build_version
        l.model_id = @model_id
        l.shipment_arrival_id = @shipment_arrival_id
        l.owner_id = @owner_id
        l.serial_number = snum
        l.box_id = boxObj.id
        l.box_serial_number = boxObj.serial_number

        l.save!
      }                           

    end

    @output["msg"] = datos["id"] ? "Cambios guardados" : "Caja agregada"  
  end

  def delete
    ids = JSON.parse(params[:payload])
    boxes = Box.find(ids)
    Box.transaction do
      boxes.each { |b|
        b.laptops.each { |l| l.destroy } 
        b.destroy
      }
    end
    
    @output["msg"] = "Elementos eliminados"
  end

  private
  def load_default_values
  
    c = LaptopConfig.find_by_key("build_version")
    if !c.value || c.value.to_s.match(/^ *$/)
      raise "Debe estar configurado el valor por defecto para version del sistema operativo"
    end
    @build_version = c.value

    c = LaptopConfig.find_by_key("model_id")
    if !c.value || c.value.to_i <= 0
      raise "Debe estar configurado el valor por defecto para el modelo de las laptops"
    end
    @model_id = c.value.to_i

    c = LaptopConfig.find_by_key("shipment_id")
    if !c.value || c.value.to_i <= 0
      raise "Debe estar configurado el valor por defecto para el cargamento"
    end
    @shipment_arrival_id = c.value.to_i

    c = LaptopConfig.find_by_key("person_id")
    if !c.value || c.value.to_i <= 0
      raise "Debe estar configurado el valor por defecto para saber en manos de quien esta la laptop"
    end
    @owner_id = c.value.to_i

    c = LaptopConfig.find_by_key("place_id")
    if !c.value || c.value.to_i <= 0
      raise "Debe estar configurado el valor por defecto para saber en que localidad estan las cajas"
    end
    @place_id = c.value.to_i

  end

end
