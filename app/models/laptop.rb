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
                                                                       
class Laptop < ActiveRecord::Base

  acts_as_audited

  has_many :movement_details
  has_many :problem_reports
  belongs_to :shipment, :class_name => "Shipment", :foreign_key => :shipment_arrival_id
  belongs_to :owner, :class_name => "Person", :foreign_key => :owner_id
  belongs_to :model
  belongs_to :status

  validates_presence_of :serial_number, :message => _("You must provide the serial number")
  validates_uniqueness_of :serial_number, :message => _("Laptop Serial Number can not be repeated")
  validates_presence_of :status_id, :message => _("You must provide the State")
  validates_presence_of :owner_id, :message => _("You must provide the Owner")

  def self.getColumnas()
    ret = Hash.new
    ret[:columnas] = [ 
                      {:name => _("Id"),:key => "laptops.id",:related_attribute => "id", :width => 50},
                      {:name => _("Created at"),:key => "laptops.created_at",:related_attribute => "created_at.to_s", :width => 80},
                      {:name => _("Serial nbr."),:key => "laptops.serial_number",:related_attribute => "getSerialNumber()", :width => 120,
                        :selected => true},
                      {:name => _("In hands of"),:key => "people.name",:related_attribute => "getOwner()", :width => 210},
                      {:name => _("Owners Doc Id"),:key => "people.id_document",:related_attribute => "getOwnerIdDoc()", :width => 80},
                      {:name => _("Code Bar Owner"), :key => "people.barcode", :related_attribute => "getOwnerBarCode()", :width => 80},
                      {:name => _("Build Version"),:key => "laptops.build_version",:related_attribute => "getBuildVersion()", :width => 120},
                      {:name => _("Shipment"),:key => "shipments.comment",:related_attribute => "getShipmentComment()", :width => 120},
                      {:name => _("Model"),:key => "models.name",:related_attribute => "getModelDescription()", :width => 120},
                      {:name => _("State"),:key => "statuses.description",:related_attribute => "getStatus()", :width => 160},
                      {:name => _("Id Box"),:key => "laptops.box_serial_number",:related_attribute => "getBoxSerialNumber()", :width => 80},
                      {:name => _("UUID"),:key => "laptops.uuid",:related_attribute => "getUuid", :width => 80},
                      {:name => _("Registered"), :key => "laptops.registered", :related_attribute => "getRegistered", :width => 50},
                      {:name => _("Last activation"), :key => "laptops.last_activation_date", :related_attribute => "getLastActivation", :width => 100}
                     ]
    ret[:columnas_visibles] = [false, false, true, true, true, false, false, false, false, true, false, false, false]
    ret 
  end

  def self.getDrillDownInfo
    {
      :object_desc => "Laptop",
      :class_name => self.to_s
    }
  end


  def before_create
    self.created_at = Time.now
    self.status_id = Status.find_by_internal_tag("deactivated").id if !self.status_id 
  end

  def before_save
    self.serial_number.upcase!
  end

  def after_create
    #TODO, register stock entrance
  end

  def getDrillDownInfo
    {
      :object_desc => "Laptop",
      :label => self.getSerialNumber().to_s,
      :class_name => self.class.to_s,
      :object_id => self.id
    }
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new
    ret["desc_col"] = 2
    ret["id_col"] = 0
    ret
  end

  def self.getBlackList
    inc = [:status]
    cond = ["statuses.internal_tag in (?)",["stolen","stolen_deactivated"]]
    black_list = Laptop.find(:all, :conditions => cond, :include => inc).map { |laptop| 
      {:serial_number => laptop.getSerialNumber } 
    }
  end

  def getBoxSerialNumber()
    self.box_serial_number ? self.box_serial_number.to_s : ""
  end

  def getOwner()
    self.owner ? self.owner.getFullName() :  ""
  end

  def getOwnerIdDoc()
    self.owner ? self.owner.getIdDoc() : ""
  end

  def getSerialNumber()
    self.serial_number
  end

  def getOwner()
    self.owner.getFullName()
  end

  def getBuildVersion()
    self.build_version ? self.build_version : ""
  end

  def getShipmentComment()
    self.shipment.getComment()
  end

  def getStatus()
	self.status.getDescription()
  end

  def getModelDescription()
    self.model_id ? self.model.getName : ""
  end

  def getDescription()
    "Laptop " +  self.getModelDescription()
  end

  def getUuid()
    self.uuid ? self.uuid : "null"
  end

  def getRegistered()
    self.registered ? _("Yes") : _("No")
  end

  def getOwnerBarCode()
    self.owner ? self.owner.getBarcode() :  ""
  end

  def getLastMovementType
    inc = [:movement_details]
    cond = ["movement_details.laptop_id = ?", self.id]
    last_movement = Movement.find(:first, :conditions => cond, :include => inc, :order => "movements.id DESC")
    last_movement ? last_movement.movement_type : nil
  end

  def getLastActivation
    self.last_activation_date ? self.last_activation_date.to_s : _("Never")
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)

    find_include = [:owner => {:performs => {:place => :ancestor_dependencies}}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    Laptop.with_scope(scope) do
      yield
    end

  end

end
