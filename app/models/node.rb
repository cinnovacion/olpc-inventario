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
                                                                         
class Node < ActiveRecord::Base
  belongs_to :place
  belongs_to :node_type

  attr_accessible :place, :place_id
  attr_accessible :node_type, :node_type_id
  attr_accessible :name, :lat, :lng, :zoom, :ip_address
  attr_accessible :last_status_change_at, :height, :username, :password
  attr_accessible :information

  validates_presence_of :name, :message => N_("Must specify the name.")
  validates_presence_of :lat, :message => N_("Must specify the Latitude")
  validates_presence_of :lng, :message => N_("Must specify the Longitude")
  validates_presence_of :zoom, :message => N_("You must specify the zoom.")
  validates_presence_of :place_id, :message => N_("You must specify the place")
  validates_presence_of :node_type_id, :message => N_("You must specify the node type.")

  before_update :register_events
  
  DEFAULT_ZOOM_VALUE = 17
  MIN_REFRESH_TIME = 15

  FIELDS = [
    {name: _("Id"), column: :id, width: 50},
    {name: _("Name"), column: :name},
    {name: _("Latitude"), column: :lat},
    {name: _("Longitude"), column: :lng},
    {name: _("Height"), column: :height},
    {name: _("Zoom"), column: :zoom},
    {name: _("Location"), association: :place, column: :name},
    {name: _("Parents Location"), association: :place, column: :name, attribute: :getParentPlaceName},
    {name: _("Type"), association: :node_type, column: :name},
    {name: _("Updated"), column: :updated_at}, 
    {name: _("IP Address"), column: :ip_address, visible: false},
    {name: _("Username"), column: :username, visible: false},
    {name: _("Password"), column: :password, visible: false},
  ]

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new
    ret["desc_col"] = 0
    ret["id_col"] = 1
    ret
  end

  def self.doRegistering(nodes_desc, place_id)
    nodes_desc.each { |node_desc|
      node = Node.find_by_id(node_desc["id"])
      if node
        node.register_update(node_desc)
      else
        Node.register(node_desc, place_id)
      end
    }
  end

  def self.getOldNodes()
    @@node_type_ids ||= NodeType.getControledTypes
    include_v = [:node_type]
    cond_v = ["node_type_id in (?) and (updated_at < ? or updated_at is null)", @@node_type_ids, MIN_REFRESH_TIME.minutes.ago]
    Node.find(:all, :conditions => cond_v, :include => include_v)
  end


  def self.markOldEntries()

    @@server_down_type_id ||= NodeType.find_by_internal_tag("server_down").id
    @@ap_down_type_id ||= NodeType.find_by_internal_tag("ap_down").id

    nodes = self.getOldNodes()

    nodes.each { |node|
      case node.node_type.internal_tag
      when "server"
        node.node_type_id = @@server_down_type_id
      when "ap"
        node.node_type_id = @@ap_down_type_id
      end
      node.setInformation({"status" => "offline"})
      node.save!
    }

    true
  end


  def self.register(node_desc, place_id)
      attribs = Node.unNodefize(node_desc)
      attribs[:place_id] = place_id
      Node.create!(attribs)
      true
  end

  def register_update(node_desc)
      attribs = Node.unNodefize(node_desc)
      self.update_attributes(attribs)
      true
  end

  def self.unNodefize(node_desc)
      attribs = Hash.new
      attribs[:name] = node_desc["name"]
      attribs[:lat] = node_desc["lat"]
      attribs[:lng] = node_desc["lng"]
      attribs[:height] = node_desc["height"]
      attribs[:node_type_id] = node_desc["type"].to_i
      attribs[:zoom] = node_desc["zoom"].to_i
      attribs[:ip_address] = node_desc["ip_address"]
      attribs
  end

  def register_events

    #Dijkstra forgive me...
    old_me = Node.find_by_id(self.id)
    if old_me && old_me.node_type_id != self.node_type_id

      self.last_status_change_at = Time.zone.now

      node_type = NodeType.find_by_id(self.node_type_id).internal_tag
      node_nature = node_type.match("^server(|_down)$") ? "server" : node_type.match("^ap(|_down)$") ? "ap" : nil
      event_type = node_type.match("^(ap|server)_down$") ? "node_down" : node_type.match("^(ap|server)$") ? "node_up" : nil

      if event_type && node_nature

        extended_info = { :id => self.id, name: self.name, :type => node_nature }
        info = extended_info.to_json
        Event.register(event_type, "system", info, self.place.id)
        NotificationsPool.register(event_type, extended_info.merge({ "subject" => self.place.getName }), place)
      end
      
    end
  end

  def getIpAddress()
    self.ip_address ? self.ip_address : ""
  end

  def getLat()
    self.lat ? self.lat : ""
  end

  def getLng()
    self.lng ? self.lng : ""
  end

  def getHeight()
    self.height ? self.height : ""
  end

  def getPlaceName()
    self.place_id ? self.place.getName() : ""
  end

  def getParentPlaceName()
    self.place && self.place.place ? self.place.place.getName() : ""
  end

  def getNodeTypeName()
    self.node_type_id ? self.node_type.name : ""
  end

  def getZoom()
    self.zoom ? self.zoom : ""
  end

  def getLastStatuschangeAt
    self.last_status_change_at ? self.last_status_change_at.getlocal.to_s : ""
  end

  def getUsername()
    self.username ? self.username : ""
  end

  def getPassword()
    self.password ? self.password : ""
  end

  def setInformation(hash)
  
    self.information = hash.to_json
  end

  def getInformation()

    self.information ? JSON.parse(self.information) : {}
  end

  def nodefize()
    node_desc = {
      :id => self.id,
      name: self.name,
      :lat => self.getLat(),
      :lng => self.getLng(),
      :height => self.getHeight(),
      :zoom => self.getZoom(),
      :type => self.node_type.name,
      :type_value => self.node_type.id,
      :icon => self.node_type.icon(),
      :ip_address => self.getIpAddress(),
      :hashed_data => self.getHashedData
    }
    node_desc
  end

  def getTotalAssociations

    total = 0

    inc = [:node_type]
    cond = ["node_types.internal_tag = ? and nodes.place_id = ?", "ap", self.place_id]
    Node.find(:all, :conditions => cond, :include => inc).each { |node|
    
      association = node.getInformation["association"]
      total +=  association ? association : 0
    }

    total
  end

  def getHashedData
    hash = Hash.new
    internal_tag = self.node_type.internal_tag
    case
      when ["ap","ap_down"].include?(internal_tag)
        hash["since"] = self.getLastStatuschangeAt
        hash.merge!(self.getInformation)

      when ["server","server_down"].include?(internal_tag)
        hash.merge!(self.getInformation)
        hash.merge!({"Total Associations" => self.getTotalAssociations})

      when "center" == internal_tag
        hash[:info] = "Punto de referencia"
        hash["Problemas pendientes"] = self.place.getProblemReports(:open)
        hash["Problemas solucionados"] = self.place.getProblemReports(:close)
    end
    hash
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)
    scope = includes({:place => :ancestor_dependencies})
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    Node.with_scope(scope) do
      yield
    end
  end

end
