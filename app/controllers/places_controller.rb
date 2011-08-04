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
                                                                       
class PlacesController < SearchController
  skip_filter :rpc_block, :only => [ :requestSchools, :requestSections, :requestSectionName, :schools_leases, :findByHostname, :show, :reportLaptops]

  attr_accessor :include_str

  def initialize
    super 
    @include_str = [:place_type]
  end

  def search
    do_search(Place,{ :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Place)
    do_search(Place,{ :include => @include_str })
  end


  def new
    
    if params[:id]
      p = Place.find(params[:id])
      @output["id"] = p.id
    else
      p = nil
    end
    
    @output["fields"] = []

    h = { "label" => _("Name"), "datatype" => "textfield" }.merge( p ? {"value" => p.name } : {} )
    @output["fields"].push(h)


    h = { "label" => _("Description"),"datatype" => "textfield" }.merge( p ? {"value" => p.description } : {} )
    @output["fields"].push(h)

    ###
    # Test for Hierarchy on Demand Widget.
    h = { "label" => _("Parent location"), "datatype" => "hierarchy_on_demand", "options" => { "width" => 360, "height" => 120 }}
    h.merge!( p && p.place ? {"dataHash" => p.place.getElementsHash } : {} )
    @output["fields"].push(h)
    #
    ###

    id = p && p.place_type ? p.place_type_id : PlaceType.find_by_internal_tag("school").id
    types = buildSelectHash2(PlaceType,id,"name",true,[])
    h = {"label" => _("Type"), "datatype" => "combobox", "options" => types}
    @output["fields"].push(h)

    h = { "datatype" => "tab_break", "title" => "Mapa" }
    @output["fields"].push(h)

   # Google Maps hello world
   #map = (p and p.nodes != []) ? p.getMap(false) : Place.defaultMap(false)
   #menu = buildSelectHash2(NodeType,-1,"name",false,[], ["icon"])
   id = p ? p.id : -1
   h = { "datatype" => "map_locator", "placeId" => id, "readOnly" => false, "width" => 400, "height" => 300 }
   @output["fields"].push(h)

  end
	
  def save

    datos = JSON.parse(params[:payload])
 
    attribs = Hash.new
    attribs[:name] = datos["fields"][0]
    attribs[:description] = datos["fields"][1]
    attribs[:place_id] = getId(datos["fields"][2])
    attribs[:place_type_id] = getId(datos["fields"][3])
    nodes = datos["fields"][4]

    if datos["id"]
      place = Place.find_by_id(datos["id"])
      place.register_update(attribs, nodes, current_user.person)
    else
      Place.register(attribs, nodes, current_user.person)
    end

    @output["msg"] = datos["id"] ? _("Changes saved.") : _("Location added.")  
  end

  def delete
    places_ids = JSON.parse(params[:payload])
    Place.unregister(places_ids, current_user.person)
    @output["msg"] = _("Elements deleted.")
  end 

  def schools
    prune = [PlaceType.find_by_internal_tag("school").id]
    cond = ["place_id is null or place_id not in (?)", Place.all.collect(&:id)]
    places = Place.find(:all, :conditions => cond)
    @output[:nodes] = places.map { |root|
      root.genTreeElements(prune)
    }
  end

  def findByHostname
    place = nil
    hostname = params[:hostname]
    if hostname
      schoolInfo = SchoolInfo.find_by_server_hostname(hostname)
      if schoolInfo
        place = schoolInfo.place
      end
    end
    render :xml => place.to_xml, :status => :ok
  end

  def show

    place = Place.find_by_id(params[:id])

    if !place
      render :text => "Lugar no encontrado", :status => 404
    else
      render :xml => place.to_xml
    end

  end

  def reportLaptops
    registered_laptops = params[:hash][:laptops_serials]
    
    if registered_laptops
      registered_laptops.each { |laptop_serial|
        laptop = Laptop.find_by_serial_number(laptop_serial[:serial_number])
        if laptop
          laptop.registered = true
          laptop.save!
        end
      }
    end

    render :xml => {}.to_xml, :status => :ok
  end

  def requestPlaces

    key = "places"
    pruneCond = nil
    pruneInc = nil
    incBlank = false

    if params[:nodes_only]
      pruneInc = [{:nodes => :node_type}]
      pruneCond = ["node_types.internal_tag = ?", "center"]
      @output[:node_types] = buildCheckHash(NodeType,"getName")
    end

    if params[:refValue]
      place_type = PlaceType.find_by_id(params[:refValue].to_i)
      place_type_tag = place_type ? place_type.internal_tag : ""
      
      pruneCond = ["place_types.internal_tag = ?",place_type_tag ]
      pruneInc = [:place_type]

      key = "cb_options"
    end

    if params[:sections_only]
      pruneCond = ["place_types.internal_tag = ? OR place_types.internal_tag LIKE '%_grade'", "section"]
      pruneInc = [:place_type]
      incBlank = true
    end

    @output[key] = buildHierarchyHash(Place, "places", "places.place_id", "name", -1, pruneCond, pruneInc, incBlank)
  end

  def requestNodes
    id = params[:id]
    subNodes = params[:subNodes] ? true : false
    nodeTypeIds = params[:nodeTypeIds] ? JSON.parse(params[:nodeTypeIds]) : []
    @output["nodes"] = []

    place = Place.find_by_id(id)
    @output["nodes"] += (subNodes ? place.getSubMapNodes(nodeTypeIds) : place.getMapNodes(nodeTypeIds)) if place
  end

  def requestMap
    id  = params[:id]
    subNodes = params[:subNodes] ? true : false

    @output["map"] = Hash.new

     place = Place.find_by_id(id)
     @output["map"] = place ? place.getMap(subNodes) : Place.defaultMap()

     @output["types"] = buildSelectHash2(NodeType,-1,"name",false,[], ["icon"])

  end

  ###
  # data source method for HierarchyOnDemand GUI Widget.
  def requestElements
    
    id = params[:id]
    subElementTags = JSON.parse(params[:subElementTags])

    if id.to_i == -1
      places = Place.roots4(current_user)
    else
      parent = Place.find_by_id(id)
      if parent.nil?
        raise _("Could not find place %d") % id
      end

      # sort certain place types alphabetically
      if parent.place_type and ["country", "state", "city"].include?(parent.place_type.internal_tag)
        order = "name"
      else
        order = nil
      end
      places = Place.find_all_by_place_id(id, :order => order)
    end

    @output[:elements] = places.map { |place|
      { :id => place.id, :text => place.name }
    }

    if subElementTags && subElementTags != []

      @output[:sub_elements] = Array.new
      inc = [:place, :person, :profile]

      if subElementTags.include?("student")

          cond = ["places.id = ? and profiles.internal_tag = ?", id, "student"]
          @output[:sub_elements] += Perform.find(:all, :conditions => cond, :include => inc).map { |perform|
            { :id => perform.person_id, :text => perform.person.getFullName() }
          }
      end

      if subElementTags.include?("teacher")

          cond = ["places.id = ? and profiles.internal_tag = ?", id, "teacher"]
          @output[:sub_elements] += Perform.find(:all, :conditions => cond, :include => inc).map { |perform|
            { :id => perform.person_id, :text => perform.person.getFullName() }
          }
      end

    end    

    true
  end

  ##
  # Restful methods
  def schools_leases

    hostnames = params[:hostnames]
    include_v = [:place]
    cond_v = (hostnames and hostnames != []) ? ["server_hostname in (?)", hostnames] : [""] 

    leases = Array.new
    t = Time.now
    now = Time.local(t.year, t.month, t.day, 6, 0) # leases should expire at 6am

    SchoolInfo.find(:all, :include => include_v, :conditions => cond_v).each { |info|

      place = info.place
      duration_secs = info.getDuration
      expiry_day = (now + duration_secs).utc.iso8601.gsub(":","").gsub("-","")

      h = Hash.new
      h[:school_name] = info.getHostname()
      h[:serials_uuids] = Place.getSerialsInfo(place.id)
      h[:expiry_date] = expiry_day

      leases.push(h)
    }

    render :xml => leases.to_xml
  end

  def requestSchools

    ret = { :list => [] }

    inc =  [:place_type]
    cond = ["place_types.internal_tag = ?","school"]
    ret[:list] = Place.find(:all, :conditions => cond, :include => inc).map { |school|
      h = Hash.new
      h[:id] = school.id
      h[:text] = school.getName
      h
    }
    render :xml => ret.to_xml
  end

  def requestSections

    ret = { :list => [] }
    school_place_id = params["id"]

    if school_place_id
      school = Place.find_by_id(school_place_id)
      if school
        sub_places_ids = school.getDescendantsIds
        inc = [:place_type]
        cond = ["places.place_id in (?) and place_types.internal_tag = ?",sub_places_ids, "section"]
        ret[:list] = Place.find(:all, :conditions => cond, :include => inc).map { |section|
          h = Hash.new
          h[:id] = section.id
          h[:text] = section.getName
          h         
        }
      end
    end
    render :xml => ret.to_xml
  end

end
