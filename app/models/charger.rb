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
                                                                       
class Charger < ActiveRecord::Base
  belongs_to :status
  belongs_to :owner, :class_name => "Person", :foreign_key => :owner_id
  belongs_to :shipment, :class_name => "Shipment", :foreign_key => :shipment_arrival_id
  has_many :parts
  has_many :movement_details

  
  # Ignoramos el numero serial - Sebastian "Radical" Codas (Tincho says: volvi a ignorar para evitar problemas con datos actuales.)
  #validates_uniqueness_of :serial_number, :message => "El nro. de serie no puede ser repetido"
  #validates_presence_of :status_id, :message => "Debe proveer el estado."
  validates_presence_of :owner_id, :message => "Debe proveer el propietario."


  def self.getColumnas()
    [ 
     {:name => "Id",:key => "chargers.id",:related_attribute => "id", :width => 50},
     {:name => "Nro. Serial", :key => "chargers.serial_number", :related_attribute => "getSerialNumber()", :width => 120,
       :selected => true},
     {:name => "En manos de",:key => "people.name",:related_attribute => "getOwner()", :width => 120},
     {:name => "Propietario CI",:key => "people.id_document",:related_attribute => "getOwnerIdDoc()", :width => 80},
     {:name => "Shipment",:key => "shipments.comment",:related_attribute => "getShipmentComment()", :width => 120},
     {:name => "Id Caja",:key => "chargers.box_serial_number",:related_attribute => "getBoxSerialNumber()", :width => 80},
     {:name => "Estado",:key => "statuses.description",:related_attribute => "getStatus()", :width => 80}
    ]
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new
    ret["desc_col"] = 1
    ret["id_col"] = 0
    ret
  end

  def getBoxSerialNumber()
    self.box_serial_number ? self.box_serial_number.to_s : ""
  end

  def before_create
    self.created_at = Time.now
    self.status_id = Status.find_by_internal_tag("deactivated").id if !self.status_id
  end

  def after_create
    Part.register_part(self,"available")
  end

  ###
  # 
  #
  def getShipmentComment()
    self.shipment.getComment()
  end

  ###
  # Who has it
  #
  def getOwner()
    self.owner.getFullName()
  end

  def getOwnerIdDoc()
    self.owner ? self.owner.getIdDoc() : ""
  end

  ###
  # Nro. Serial
  #
  def getSerialNumber()
    self.serial_number
  end


  ##
  # charger desc
  #
  def getDescription()
    "Cargador"
  end

  ##
  # Estado
  #
  def getStatus()
     self.status.getDescription()
  end

  def getSubPartsOn
    cond = ["parts.on_device_serial = ? and parts.charger_id is not NULL", self.getSerialNumber]
    Part.find(:all, :conditions => cond)
  end

  def getLastMovementType
    inc = [:movement_details]
    cond = ["movement_details.charger_id = ?", self.id]
    last_movement = Movement.find(:first, :conditions => cond, :include => inc, :order => "movements.id DESC")
    last_movement ? last_movement.movement_type : nil
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:owner => {:performs => {:place => :ancestor_dependencies}}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    Charger.with_scope(scope) do
      yield
    end

  end

end
