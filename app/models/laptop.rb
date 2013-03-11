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
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
#
# Author: Martin Abente
# E-mail Address:  (tincho_02@hotmail.com | mabente@paraguayeduca.org) 

class Laptop < ActiveRecord::Base
  audited

  has_many :movements
  has_many :assignments
  has_many :problem_reports
  has_many :connection_events, inverse_of: :laptop
  belongs_to :shipment, :class_name => "Shipment", :foreign_key => :shipment_arrival_id
  belongs_to :owner, :class_name => "Person", :foreign_key => :owner_id
  belongs_to :assignee, :class_name => "Person", :foreign_key => :assignee_id
  belongs_to :model
  belongs_to :status

  attr_accessible :serial_number, :uuid, :registered, :last_activation_date
  attr_accessible :model, :model_id, :status, :status_id
  attr_accessible :owner, :owner_id, :assignee, :assignee_id
  attr_accessible :shipment_arrival, :shipment_arrival_id

  validates_presence_of :serial_number, :message => N_("You must provide the serial number")
  validates_uniqueness_of :serial_number, :message => N_("Laptop Serial Number can not be repeated")
  validates_presence_of :owner_id, :message => N_("You must provide the Owner")

  before_save { |laptop| laptop.serial_number.upcase! }
  before_create { |laptop|
    laptop.status_id = Status.deactivated.id if !self.status_id 
  }

  def self.getColumnas()
    ret = Hash.new
    ret[:columnas] = [ 
                      {:name => _("Id"),:key => "laptops.id",:related_attribute => "id", :width => 50},
                      {:name => _("Created at"),:key => "laptops.created_at",:related_attribute => "created_at.to_s", :width => 80},
                      {:name => _("Serial nbr."),:key => "laptops.serial_number",:related_attribute => "serial_number", :width => 120,
                        :selected => true},
                      {:name => _("In hands of"),:key => "people.name",:related_attribute => "owner", :width => 210},
                      {:name => _("Owners Doc Id"),:key => "people.id_document",:related_attribute => "owner.id_document", :width => 80},
                      {:name => _("Code Bar Owner"), :key => "people.barcode", :related_attribute => "owner.barcode", :width => 80},
                      {:name => _("Assigned to"),:key => "people.name",:related_attribute => "getAssignee", :width => 210},
                      {:name => _("Assignee Doc Id"),:key => "people.id_document",:related_attribute => "getAssigneeIdDoc", :width => 210},
                      {:name => _("Model"),:key => "models.name",:related_attribute => "model", :width => 120},
                      {:name => _("State"),:key => "statuses.description",:related_attribute => "status", :width => 160},
                      {:name => _("UUID"),:key => "laptops.uuid",:related_attribute => "uuid", :width => 80},
                      {:name => _("Registered"), :key => "laptops.registered", :related_attribute => "getRegistered", :width => 50},
                      {:name => _("Last activation"), :key => "laptops.last_activation_date", :related_attribute => "getLastActivation", :width => 100}
                     ]
    ret[:columnas_visibles] = [false, false, true, true, true, false, true, true, false, false, false, false, false]
    ret 
  end

  def self.getDrillDownInfo
    {
      :object_desc => "Laptop",
      :class_name => self.to_s
    }
  end

  def getDrillDownInfo
    {
      :object_desc => "Laptop",
      :label => self.serial_number,
      :class_name => self.class.to_s,
      :object_id => self.id
    }
  end

  def self.getChooseButtonColumns(vista = "")
    {
      "desc_col" => 2,
      "id_col" => 0,
    }
  end

  def self.getBlackList
    Status.stolen.laptops.map { |laptop|
      { :serial_number => laptop.serial_number, :uuid => laptop.uuid }
    }
  end

  def getAssignee()
    self.assignee ? self.assignee.getFullName() :  ""
  end

  def getAssigneeIdDoc()
    self.assignee ? self.assignee.getIdDoc() :  ""
  end
 
  def getDescription()
    "Laptop " +  self.model.to_s
  end

  def getRegistered()
    self.registered ? _("Yes") : _("No")
  end

  def last_movement_type
    last_movement = self.movements.order("movements.id DESC").first
    last_movement ? last_movement.movement_type : nil
  end

  def getLastActivation
    self.last_activation_date ? self.last_activation_date.to_s : _("Never")
  end

  # Imports the Quanta production spreadsheet.
  # attribs must provide :arrived_at, for shipment creation.
  # And for laptop creation: model_id, owner_id, status_id
  def self.import_xls(filename, attribs)
   _shipment = 0
   _laptop_serial = 3

    Laptop.transaction do
      Spreadsheet.open(filename).worksheet(0).each { |row|
        next if row == nil
        dataArray = row.map { |cell| cell ? cell.to_s : "" }

        #First we check if the shipment exists, else we created it.
        shipment = Shipment.find_by_shipment_number(dataArray[_shipment])
        if !shipment
          shipment = {
            shipment_number: dataArray[_shipment],
            arrived_at: attribs[:arrived_at],
            comment: "##{dataArray[_shipment]} from mass import",
          }
          shipment = Shipment.create!(shipment)
        end

        laptop = {
          serial_number: dataArray[_laptop_serial],
          model_id: attribs[:model_id],
          shipment_arrival_id: shipment.id,
          owner_id: attribs[:owner_id],
          status_id: attribs[:status_id]
        }
        Laptop.create!(laptop)
      }
    end
  end

  def self.import_uuids_from_csv(filename)
    File.open(filename).each { |row|
      next if row == nil
      data = row.split(/[ ,]/).map { |column| column.strip }
      laptop = Laptop.find_by_serial_number!(data[0])
      laptop.update_attributes!(uuid: data[1])
    }
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)
    scope = includes(:owner => {:performs => {:place => :ancestor_dependencies}})
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    Laptop.with_scope(scope) do
      yield
    end
  end
end
