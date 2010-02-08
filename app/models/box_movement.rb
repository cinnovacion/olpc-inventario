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
                                                                         
class BoxMovement < ActiveRecord::Base

  belongs_to :src_place, :class_name => "Place", :foreign_key => :src_place_id
  belongs_to :src_person, :class_name => "Person", :foreign_key => :src_person_id
  belongs_to :dst_place, :class_name => "Place", :foreign_key => :dst_place_id 
  belongs_to :dst_person, :class_name => "Person", :foreign_key => :dst_person_id
  belongs_to :authorizer, :class_name => "Person", :foreign_key => :authorized_person_id

  has_many :box_movement_details

 
  validates_presence_of :date_moved_at, :message => "Debe proveer la fecha del movimiento de caja"   
  validates_presence_of :src_place_id, :message => "Debe proveer la localidad de origen de la caja"
  validates_presence_of :src_person_id, :message => "Debe proveer la persona que posee las cajas actualmente"
  validates_presence_of :dst_place_id, :message => "Debe proveer la localidad destino de la caja"
  validates_presence_of :dst_person_id, :message => "Debe proveer a manos de quien va la caja"
  validates_presence_of :authorized_person_id, :message => "Debe proveer la persona que autorizo la caja"


  def self.getColumnas()
    ret = Hash.new
    
    ret[:columnas] = 
      [ 
       {:name => "Id",:key => "box_movements.id",:related_attribute => "id", :width => 50},
       {:name => "Fch. Mov",:key => "box_movements.date_moved_at",:related_attribute => "getDate()", :width => 120},
       {:name => "Localidad Origen",:key => "places.name",:related_attribute => "getSrcPlace()",
         :width => 80},
       {:name => "Persona Origen",:key => "people.name",:related_attribute => "getSrcPerson()", 
         :width => 120},
       {:name => "Localidad Destino", :key => "dst_places_box_movements.name", :related_attribute => "getDstPlace()", :width => 120},
       {:name => "Persona Destino",:key => "dst_people_box_movements.name",:related_attribute => "getDstPerson()",
         :width => 120},
       {:name => "Autorizado por",:key => "authorizers_box_movements.name",:related_attribute => "getAuthorizer()",
         :width => 120},
       {:name => "Cant. Cajas",:key => "box_movements.id",:related_attribute => "getNumBoxes()",
         :width => 120}

      ]

    ret[:columnas_visibles] = [false, true, true, true, true, true, true ]

    ret
  end


  ######
  # 1) se da de alta el movimiento
  # 2) se registran los detalles
  # 3) validaciones: 
  #    - que coincida origen del movimiento con origen de las cajas
  #    - que las laptops esten en manos de quien se dice que tiene que estar
  # 4) efectos secundarios:
  #   - se cambia el place_id de las cajas
  #   - se cambia el owner_id de las laptops
  def self.crear(movementData, box_ids)

    BoxMovement.transaction do

      movObj = self.create!(movementData)


      box_ids.each { |box_id|
        movObj.box_movement_details.create!( { :box_id => box_id } )
      }

      # validaciones
      # si esta todo bien:
      # - se cambia el place_id de las cajas
      # - se cambia el owner_id de las laptops
      movObj.box_movement_details.each { |bmd|

      if movObj.src_place_id != bmd.box.place_id
        serial_num = bmd.box.serial_number
        box_place = bmd.box.place.name
        raise "La caja con nro serial #{serial_num} se encuentra en #{box_place} "
      end

      bmd.box.laptops.each { |lap|

      if lap.owner_id != movObj.src_person_id
        serial_num = lap.getSerialNumber()
        mov_src_person = movObj.src_person.getFullName()
        hands_off = lap.owner.getFullName()
	err_msg =  "La laptop con # serial #{serial_num} no esta en manos de #{mov_src_person}. "
	err_msg += "Esta en manos de #{hands_off}"
	raise err_msg
      end

      lap.owner_id = movObj.dst_person_id
      lap.save!
      }
        bmd.box.place_id = movObj.dst_place_id
        bmd.box.save!
      }

    end

  end


  def getNumBoxes()
    self.box_movement_details.length
  end

  def before_create
    self.created_at = Time.now
  end

  def getDate()
    self.date_moved_at.to_s
  end

  def getSrcPlace()
    self.src_place.getName()
  end

  def getSrcPerson()
    self.src_person.getFullName()
  end

  def getDstPlace()
    self.dst_place.getName()
  end

  def getDstPerson()
    self.dst_person.getFullName()
  end

  def getAuthorizer()
    self.authorizer.getFullName()
  end



end
