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

    @output["with_tabs"] = true
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
    places = Place.where("place_id is null or place_id not in (?)", Place.all.collect(&:id))
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

  def mapPlaces(places, levels)
    places.map { |place|
      element = { :id => place.id, :text => place.name }

      if levels > 0
        children = place.places

        # sort certain place types alphabetically
        if place.place_type and ["country", "state", "city"].include?(place.place_type.internal_tag)
          children = children.order("name")
        end

        if children.any?
          element[:children] = mapPlaces(children, levels - 1)
        end
      end
      element
    }
  end

  ###
  # data source method for HierarchyOnDemand GUI Widget.
  def requestElements
    skip_toplevel_place = false
    id = params[:id]
    subElementTags = JSON.parse(params[:subElementTags])

    if id.to_i == -1
      places = current_user.getRootPlaces()
    else
      parent = Place.find_by_id(id)
      if parent.nil?
        raise _("Could not find place %d") % id
      end
      places = [parent]
      skip_toplevel_place = true
    end

    mapped_places = self.mapPlaces(places, 1)
    if skip_toplevel_place
      @output[:elements] = mapped_places[0][:children]
    else
      @output[:elements] = mapped_places
    end

    if subElementTags && subElementTags != []

      @output[:sub_elements] = Array.new
      performs = Perform.includes(:place, :person, :profile)
      performs = performs.where("places.id = ?", id)
      select_profiles = []

      if subElementTags.include?("student")
          select_profiles.push("student")
      end

      if subElementTags.include?("teacher")
          select_profiles.push("teacher")
      end

      if select_profiles.any?
          performs = performs.where("profiles.internal_tag" => select_profiles)
          @output[:sub_elements] += performs.map { |perform|
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
    schools = SchoolInfo.includes(:place)
    if hostnames and hostnames != []
      schools = schools.where(:server_hostname => hostnames)
    end

    leases = Array.new

    schools.each { |info|
      if info.getDuration.nil?
        t = info.getExpiry
      else
        t = Time.now
        t += info.getDuration * 3600 * 24
      end

      expiry = Time.local(t.year, t.month, t.day, 6, 0) # leases should expire at 6am
      expiry = expiry.utc.iso8601.gsub(":","").gsub("-","")

      h = Hash.new
      h[:school_name] = info.getHostname()
      h[:serials_uuids] = Place.getSerialsInfo(info.place_id)
      h[:expiry_date] = expiry

      leases.push(h)
    }

    render :xml => leases.to_xml
  end

  def requestSchools

    ret = { :list => [] }

    places = Place.includes(:place_type).where("place_types.internal_tag = 'school'")
    ret[:list] = places.map { |school|
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
        places = Place.includes(:place_type).where(:place_id => sub_places_ids)
        places = places.where("place_types.internal_tag = 'section'")
        ret[:list] = places.map { |section|
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
