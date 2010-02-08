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
                                                                        
class NodesController < SearchController

  skip_filter :rpc_block, :only => [:setInformation, :allNodesAt]
  ##
  # Actions for remote node control and status update
  def setInformation

    node  = Node.find_by_id(params[:hash][:id].to_i)
    information = params[:hash][:information]

    status = information[:status] == "online" ? "" :  "_down"

    old_type_tag = node.node_type.internal_tag

    new_type_tag = nil    
    new_type_tag =  "ap#{status}" if old_type_tag.match("^ap(_down|)$")
    new_type_tag =  "server#{status}" if old_type_tag.match("^server(_down|)$")

    node.node_type_id = NodeType.find_by_internal_tag(new_type_tag).id
    node.setInformation(information)
    node.save!

    render :xml => node.to_xml, :status => :ok
  end

  def allNodesAt

    hostname = params[:hostname]
    place_id = SchoolInfo.find_by_server_hostname(hostname).place_id
    place = Place.find_by_id(place_id)

    nodes = []
    cond = ["node_type_id in (?)", NodeType.getControledTypes]
    place.nodes.find(:all, :conditions => cond).each { |node| 
      
      nodes.push({ :id => node.id, :ip_address => node.ip_address, :username => node.username, :password => node.password })
    }

    render :xml => nodes.to_xml
  end #
  #####

  attr_accessor :include_str

  def initialize
    super 
    @include_str = [:node_type]
  end

  def search
    do_search(Node,{ :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Node)
    do_search(Node,{ :include => @include_str })
  end

  def new

    if params[:id]
      node = Node.find(params[:id])
      @output["id"] = node.id
    else
      node = nil
    end

    @output["fields"] = []

    h = { "label" => "Nombre","datatype" => "textfield" }.merge( node ? {"value" => node.getName } : {} )
    @output["fields"].push(h)

    h = { "label" => "Latitud","datatype" => "coords_text_field" }.merge( node ? {"value" => node.getLat } : {} )
    @output["fields"].push(h)

    h = { "label" => "Longitud","datatype" => "coords_text_field" }.merge( node ? {"value" => node.getLng } : {} )
    @output["fields"].push(h)

    h = { "label" => "Altura","datatype" => "textfield" }.merge( node ? {"value" => node.getHeight } : {} )
    @output["fields"].push(h)

    val = node ? node.getZoom : Node::DEFAULT_ZOOM_VALUE
    h = { "label" => "Zoom","datatype" => "textfield", "value" => val }
    @output["fields"].push(h)

    id = (node && node.place) ? node.place_id : -1
    places = buildHierarchyHash(Place, "places", "places.place_id", "name", id, nil, nil, false)
    h = { "label" => "Localidad","datatype" => "select","options" => places, "option" => "localidades" }
    @output["fields"].push(h)

    id = (node && node.node_type) ? node.node_type_id : -1
    types = buildSelectHash2(NodeType,id,"getName",true,[])
    h = { "label" => "Tipo","datatype" => "combobox","options" => types }
    @output["fields"].push(h)

    h = { "label" => "Direccion Ip", "datatype" => "textfield" }.merge( node ? {"value" => node.getIpAddress } : {} )
    @output["fields"].push(h)

    h = { "label" => "Username","datatype" => "textfield" }.merge( node ? {"value" => node.getUsername } : {} )
    @output["fields"].push(h)

    h = { "label" => "Password","datatype" => "textfield" }.merge( node ? {"value" => node.getPassword } : {} )
    @output["fields"].push(h)

  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse
    attribs = Hash.new

    attribs[:name] = data_fields.pop
    attribs[:lat] = data_fields.pop
    attribs[:lng] = data_fields.pop
    attribs[:height] = data_fields.pop
    attribs[:zoom] = data_fields.pop
    attribs[:place_id] = data_fields.pop
    attribs[:node_type_id] = data_fields.pop
    attribs[:ip_address] = data_fields.pop
    attribs[:username] = data_fields.pop
    attribs[:password] = data_fields.pop
    
    if datos["id"]
      node = Node.find_by_id(datos["id"])
      node.update_attributes(attribs)
    else
      Node.create!(attribs)
    end

    @output["msg"] = datos["id"] ? "Cambios guardados." : "Nodo agregado."
  end

  def delete
    ids = JSON.parse(params[:payload])
    Node.destroy(ids)
    @output["msg"] = "Elementos eliminados"
  end

  ##
  # updateNode function from Network Control app
  # based on google maps.
  def updateNode
    node_desc = JSON.parse(params[:node])
    node = Node.find_by_id(node_desc["id"])
    node.register_update(node_desc) if node
    @output["node"] = node.nodefize
  end

end
