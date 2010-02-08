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

# # #
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 
# 2009
# # #
                                                                       
class Movement < ActiveRecord::Base
  belongs_to :person_responsible, :class_name => "Person", :foreign_key => :responsible_person_id
  belongs_to :source_person, :class_name => "Person", :foreign_key => :source_person_id 
  belongs_to :destination_person, :class_name => "Person", :foreign_key => :destination_person_id
  belongs_to :movement_type 
  has_many :movement_details

  
  validates_presence_of :source_person_id, :message => "Debe decir quien entrega"
  validates_presence_of :destination_person_id, :message => "Debe decir quien recibe"


  def self.getColumnas()
    [ 
     {:name => "Nro. Mov",:key => "movements.id",:related_attribute => "id", :width => 50},
     {:name => "Fch. Mov.",:key => "movements.date_moved_at",:related_attribute => "getMovementDate()", :width => 90},
     {:name => "Hora Mov.",:key => "movements.time_moved_at",:related_attribute => "getMovementTime()", :width => 90},
     {:name => "Tipo", :key => "movement_types.description", :related_attribute => "getMovementType()", :width => 150},
     {:name => "Serial", :key => "laptops.serial_number", :related_attribute => "getLaptopSerial()", :width => 150},
     {:name => "Entrego",:key => "people.name",:related_attribute => "getSourcePerson()", :width => 180},
     {:name => "Recibio",:key => "destination_people_movements.name",:related_attribute => "getDestinationPerson()", :width => 180},
     {:name => "Recibio (CI)",:key => "destination_people_movements.id_document",:related_attribute => "getDestinationPerson()", :width => 180},
     {:name => "Comentario",:key => "movements.comment",:related_attribute => "getComment()", :width => 160}
    ]
  end

  
  ###
  # Statistics 
  #
  def self.getNumberOf(what)
    mt = nil

    case what
    when "for_repair"
      itag = "reparacion"
    when "repaired"
      itag = "reparacion_finalizada"
    when "developer"
      itag = "uso_desarrollador"
    when "loaned"
      itag = "prestamo"
    when "teachers"
      itag = "entrega_docente"
    when "students"
      itag = "entrega_alumno"
    when "formadores"
      itag = "entrega_formador"
    when "returned"
      itag = "devolucion"
    when "first_boot_problem"
      itag = "devolucion_problema_tecnico_entrega" 
    end

    mt = MovementType.find_by_internal_tag itag
    
    self.count(:conditions => ["movement_type_id = ?", mt.id])
  end

  def self.for_device(device, to_person, movement_type_tag)

    movement_type = MovementType.find_by_internal_tag(movement_type_tag)
    serial_sym = "serial_number_#{device.class.to_s.downcase}".to_sym
    attribs = Hash.new
    attribs[:id_document] = to_person.getIdDoc()
    attribs[:movement_type_id] = movement_type.id
    attribs[serial_sym] = device.getSerialNumber()
    attribs[:comment] = "Entrega desde el modulo de CATS"
    Movement.register(attribs)
  end


  ###
  # Theres only one detail, the reason is that theres no battery and charger model anymore
  def self.register(attribs)
    Movement.transaction do

      device_status = nil

      #Updating Laptop stats
      movement_type = MovementType.find_by_id(attribs[:movement_type_id])
      raise "Tipo de movimiento invalido" if !movement_type
      if movement_type.is_delivery?
        device_status = Status.find_by_internal_tag("activated")
      else
        if movement_type.is_return?
          device_status = Status.find_by_internal_tag("deactivated")
        end
      end

      m = Movement.new
      m.responsible_person_id = attribs[:responsible_person_id] if attribs[:responsible_person_id]
      
      lapObj = nil
      source_person_id = -1

      if attribs[:serial_number_laptop] && !attribs[:serial_number_laptop].to_s.match(/^ *$/)
        lapObj = Laptop.find_by_serial_number(attribs[:serial_number_laptop])
        source_person_id = lapObj.owner_id
      end

      m.source_person_id = source_person_id
      personObj = Person.find_by_id_document(attribs[:id_document])
      if !personObj
        raise "No pude encontrar a la persona con CI #{attribs[:id_document]}"
      end

      m.destination_person_id = personObj.id
      m.comment = attribs[:comment]
      m.return_date = attribs[:return_date] if attribs[:return_date] && !attribs[:return_date].to_s.match(/^ *$/)
      m.movement_type_id = attribs[:movement_type_id]
      m.save!

      #Checking movements FSM
      last_movement_type = lapObj.getLastMovementType
      if !MovementType.check(last_movement_type, movement_type)
        error_str = "El movimiento a realizarse sobre #{device.getSerialNumber} no corresponde a su ultimo movimiento,"
        error_str += "el movimiento anterior fue #{last_movement_type.description}"
        raise error_str
      end

      # Saving details
      d = Hash.new
      d[:laptop_id] = lapObj.id  
      m.movement_details.create!(d)

      #Updating owner
      lapObj.owner_id = m.destination_person_id
      lapObj.status_id = device_status.id if device_status
      lapObj.save!

    end
  end

  def before_save
    raise "Los prestamos REQUIEREN fecha de retorno." if !self.return_date and self.movement_type.internal_tag == "prestamo"
    raise "Solo los prestamos requieren fecha de retorno." if self.return_date and self.movement_type.internal_tag != "prestamo"
    self.created_at = self.date_moved_at = self.time_moved_at = Time.now
  end
  
  def getMovementDate()
    self.date_moved_at.to_s
  end

  def getMovementTime()
    Fecha::getHora(self.time_moved_at)
  end

  def getResponsible()
    self.person_responsible ? self.person_responsible.getFullName() : ""
  end

  def getSourcePerson()
    self.source_person ? self.source_person.getFullName() : ""
  end

  def getDestinationPerson()
    self.destination_person ? self.destination_person.getFullName() : ""
  end

  def getComment()
    self.comment
  end

  def getMovementType()
    return self.movement_type.description if self.movement_type
    "null"
  end

  def getParts()
    s = String.new
    self.movement_details.each { |p|
      s+= "#{p.description},"
    }
    s
  end

  def getReturnDate()
    self.return_date.to_s
  end

  def getLaptopSerial()
    (self.movement_details && self.movement_details.first) ? self.movement_details.first.laptop.getSerialNumber : ""
  end

  ##
  # List all the lendings with expired return_date
  def self.expiredLendings(expiredBy = Time.now)

    people = Hash.new

    inc_v = [:movement_details, :destination_person]
    cond_v = ["return_date is not null and movement_details.returned = ? and movements.return_date < ?", false, expiredBy]
    self.find(:all, :conditions => cond_v, :include => inc_v).each { |m|

      person = m.destination_person
      m.movement_details.each { |md|
            
            people[person] = Hash.new if !people[person]
            device_class = md.device.class.name.pluralize
            people[person][device_class] = people[person][device_class] ? people[person][device_class]+1 : 1
      }
    }

    
    people.keys.map { |person| 

      msg = "Estimado(a) #{person.getFullName}:\n"
      msg += "Le recordamos que estan en su posecion los siguientes dispositivos, los cuales deben ser devueltos a las oficnas de Paraguay Educa\n"
      msg += people[person].keys.map { |device_class| "#{device_class}: #{people[person][device_class]}\n" }.join()
      msg += "Favor comunicarse a info@paraguayeduca.org"
      Notifier.deliver_lendings_reminder(person.email, msg)
    }
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:destination_person => {:performs => {:place => :ancestor_dependencies}}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    Movement.with_scope(scope) do
      yield
    end

  end

end
