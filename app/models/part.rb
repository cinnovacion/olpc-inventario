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
                                                                       
class Part < ActiveRecord::Base
  belongs_to :status
  belongs_to :part_type
  belongs_to :owner, :class_name => "Person", :foreign_key => :owner_id
  belongs_to :laptop
  belongs_to :battery
  belongs_to :charger

  def self.getColumnas()
    [ 
     {:name => "Id",:key => "parts.id",:related_attribute => "id", :width => 50},
     {:name => "Estado",:key => "statuses.description",:related_attribute => "getStatusDescription()", :width => 120},
     {:name => "Propietario",:key => "people.name",:related_attribute => "getOwner()", :width => 120},
     {:name => "Propietario (CI)",:key => "people.id_document",:related_attribute => "getOwnerIdDoc()", :width => 120},
     {:name => "Tipo",:key => "part_types.description",:related_attribute => "getPartDescription()", :width => 120},
     #{:name => "#Laptop",:key => "laptops.serial_number",:related_attribute => "getLaptopSerial", :width => 120},
     #{:name => "#Bateria",:key => "batteries.serial_number",:related_attribute => "getBatterySerial", :width => 120},
     #{:name => "#Cargador",:key => "chargers.serial_number",:related_attribute => "getChargerSerial", :width => 120},
     {:name => "Numero Serial", :key => "parts.on_device_serial", :related_attribute => "getOnDeviceSerial", :width => 120}
    ]
  end


  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new

    case vista
    when ""
      ret["desc_col"] = 4
      ret["id_col"] = 0
    end
    ret
  end

  def before_create
    self.on_device_serial = self.getParentSerial
  end

  def getOnDeviceSerial
    self.on_device_serial ? self.on_device_serial : ""
  end

  def getStatusDescription()
    ret = self.status ? self.status.getDescription() : ""
  end

  def getOwner()
    ret = self.owner ? self.owner.getFullName() : ""
  end

  def getOwnerIdDoc()
    ret = self.owner ? self.owner.getIdDoc() : ""
  end

  def getPartDescription()
    ret = self.part_type ? self.part_type.getDescription() : ""
  end

  def getLaptopSerial()
    ret = self.laptop_id ? self.laptop.getSerialNumber() : ""
  end

  def getBatterySerial()
    ret = self.battery_id ? self.battery.getSerialNumber() : ""
  end

  def getChargerSerial()
    ret = self.charger_id ? self.charger.getSerialNumber() : ""
  end

  def self.register(attribs, ignoreControl = false)
    if !ignoreControl && Part.partExists(attribs[:laptop_id], attribs[:battery_id], attribs[:charger_id], attribs[:part_type_id])
      raise "Esta parte ya ha sido registrada en el sistema."
    end
    Part.create(attribs)
  end

  def self.register_spare_parts(impure_attribs, register)


    part_type = PartType.find_by_id(impure_attribs[:part_type_id])
    amount = impure_attribs[:amount]

    device_part_type = PartType.find_by_id(impure_attribs[:device_part_type_id])
    device_str = device_part_type.internal_tag
    ghost_device_serial = impure_attribs[:ghost_device_serial]
    device_class = device_str.camelize.constantize
    ghost_device = device_class.find_by_serial_number(ghost_device_serial)
    device_owner = ghost_device.owner

    status = Status.find_by_internal_tag("available")

    raise "Los datos son insuficientes" if !(part_type && register && ghost_device && device_owner && status)
    raise "Las partes de repuestos solo debe asignarse a dispositivos fantasma" if !ghost_device.is_ghost

    Part.transaction do

      amount.times do

        attribs = Hash.new
        attribs[:owner_id] = device_owner.id
        attribs[:part_type_id] = part_type.id
        attribs["#{device_str}_id".to_sym] = ghost_device.id
        attribs[:on_device_serial] = ghost_device_serial
        attribs[:status_id] = status.id
  
        register(attribs, true)
      end

      SparePartsRegistry.register(register, amount, part_type, device_owner, ghost_device_serial)
    end

  end

  def self.getAttribsOwner(attribs)
    
    laptop = Laptop.find_by_id(attribs[:laptop_id])
    battery = Battery.find_by_id(attribs[:battery_id])
    charger = Charger.find_by_id(attribs[:charger_id])
    purge_collection = [laptop, battery, charger]
    purge_collection.delete(nil)
    device = purge_collection.pop
    device.send("owner_id")
    
  end

  def self.register_part(record, status, part_type_str = nil)
    part = Part.new
    part.status_id = Status.find_by_internal_tag(status).id
    part_str = record.class.to_s.downcase
    part_fk_id = part_str + "_id="
    part.send(part_fk_id.to_sym, record.id)
    part.part_type_id = PartType.find_by_internal_tag(part_type_str ? part_type_str : part_str).id
    part.owner_id = record.owner ? record.owner_id : nil
    return part if part.save!
    nil
  end

  def self.modify_part_status_as( record, status_tag)

    new_status = Status.find_by_internal_tag(status_tag)
    record.getSubPartsOn.each { |sub_part|

      sub_part.status_id = new_status.id
      sub_part.save
    }
    true
  end

  def self.partExists(laptop_id, battery_id, charger_id, part_type_id)
    return true if Part.find_by_laptop_id_and_battery_id_and_charger_id_and_part_type_id(laptop_id,battery_id,charger_id,part_type_id)
    false
  end

  def getParent
    return self.laptop if self.laptop_id
    return self.battery if self.battery_id
    self.charger
  end

  def getParentType()
    return "laptop" if self.laptop_id
    return "battery" if self.battery_id
    "charger"
  end

  def getParentSerial()
    return self.laptop.getSerialNumber if self.laptop_id
    return self.battery.getSerialNumber if self.battery_id
    self.charger.getSerialNumber if self.charger_id
  end

  def self.updateOwner(record)

    new_status = nil
    main_sub_part_type_tag = record.class.to_s.downcase
    main_sub_part = Part.findPart(record)
    main_sub_part_status = main_sub_part.status

    case main_sub_part_status.internal_tag
      when "used"
        new_status = main_sub_part_status
      when "broken"
        new_status = Status.find_by_internal_tag("available")
    end

    Part.transaction do
      record.getSubPartsOn.each { |subPart|

        if new_status && subPart.part_type.internal_tag != main_sub_part_type_tag
          subPart.status_id = new_status.id
        end

        subPart.owner_id = record.owner_id
        subPart.save!
      }
    end
  end

  def self.findPart(record, part_type_tag = nil, status_tag = nil)

    device_str = record.class.to_s.downcase
    part_type_tag = part_type_tag ? part_type_tag : device_str

    inc  = [:part_type]
    cond = [" parts.on_device_serial = ? and part_types.internal_tag = ?", record.getSerialNumber, part_type_tag]

    if status_tag

      inc += [:status]
      cond[0] += " and statuses.internal_tag = ?"
      cond.push(status_tag)
    end

    Part.find(:first, :conditions => cond, :include => inc)
  end

  def self.isValidReplacement?(device)

    statuses_tags = []
    device.getSubPartsOn.each { |sub_part| 
    
      status_tag = sub_part.status.internal_tag
      statuses_tags.push(status_tag) if !statuses_tags.include?(status_tag) 
    }
    
    return ((statuses_tags - ["available"]).length == 0)
  end
 
  def isMainPart?
    return true if self.part_type.internal_tag.match("^laptop|battery|charger$")
    false
  end

  #def setMainPartAs!(status)

    #device = self.getParent

    #main_part = Part.findPart(device, device.class.to_s.downcase)
    #main_part.status_id = status.id
    #main_part.save!
  #end

  def mainPart

    inc = [:part_type]
    cond = ["part_types.internal_tag = ? and parts.on_device_serial = ?", getParentType, on_device_serial]
    Part.find(:first, :conditions => cond, :include => inc)
  end

  def setMainPartAs!(status)

    main_part = self.mainPart
    main_part.status_id = status.id
    main_part.save!
  end

  def self.swaps!(src_part, dst_part, src_status = nil, dst_status = nil)

    src_part.status_id = src_status.id if src_status
    dst_part.status_id = dst_status.id if dst_status

    aux_owner_id = src_part.owner_id
    aux_on_device_serial = src_part.on_device_serial

    src_part.owner_id = dst_part.owner_id
    src_part.on_device_serial = dst_part.on_device_serial

    dst_part.owner_id = aux_owner_id
    dst_part.on_device_serial = aux_on_device_serial

    src_part.save!
    dst_part.save!
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:owner => {:performs => {:place => :ancestor_dependencies}}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    Part.with_scope(scope) do
      yield
    end

  end

end
