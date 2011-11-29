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
                                                                         
class Place < ActiveRecord::Base

  acts_as_audited

  belongs_to :place
  belongs_to :place_type
  has_many :events
  has_many :places
  has_many :performs
  has_many :people, :through => :performs, :source => :person
  has_many :ancestor_dependencies, :foreign_key  => "descendant_id", :class_name => "PlaceDependency"
  has_many :descendant_dependencies, :foreign_key  => "ancestor_id", :class_name => "PlaceDependency"
  has_many :descendants, :through => :descendant_dependencies, :source => :descendant
  has_many :ancestors, :through => :ancestor_dependencies, :source => :ancestor
  has_many :nodes
  has_many :problem_reports
  has_one :school_info

  before_create :set_created_at_and_ancestors
  after_create :register_place_dependencies
  before_update :update_place_dependencies
  before_destroy :unregister_place_dependencies
  
  ###
  # Listado
  #
  def self.getColumnas(vista = "")
    ret = Hash.new
    
    ret[:columnas] = [ 
                      {:name => _("Id"),:key => "places.id",:related_attribute => "id", :width => 50},
                      {:name => _("Creation Date"),:key => "places.description", 
                        :related_attribute => "getDate()", :width => 120},
                      {:name => _("Name"),:key => "places.name",:related_attribute => "getName()", :width => 325},
                      {:name => _("Description"),:key => "places.description",:related_attribute => "getDescription()",
                        :width => 150},
                      {:name => _("Type"),:key => "place_types.name",:related_attribute => "getType()", :width => 100}
                     ]

    ret[:columnas_visibles] = [true, true, true, true, true]
    
    #Theres obviously a better way to do this, but for now it works.
    #case vista
      #when "teaches"
      #  ret[:conditions] = ["place_type_id in (?)", PlaceType.getGradeTypes()]
      #when /\d/
        #ret[:conditions] = ["place_type_id in (?) and place_id in  (?)", PlaceType.find_by_internal_tag("section").id, Place.find(vista).getDescendantsIds]
    #end

    ret
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new
    ret["desc_col"] = 2
    ret["id_col"] = 0
    ret
  end


  ###
  # Returns list of serial_nums and uuids of all laptops in a place
  #
  def self.getSerialsInfo(place_id)
    ret = Array.new

    place = Place.find_by_id(place_id)
    return ret if not place

    places_ids = place.getDescendantsIds + [place_id] + place.getAncestorsIds
    people_ids = Perform.find_all_by_place_id(places_ids).collect(&:person_id)

    cond_v = "serial_number is not NULL and serial_number != \"\""
    cond_v += " and uuid is not NULL and uuid != \"\""
    cond_v += " and status_id is not NULL and statuses.internal_tag = \"activated\""
    cond_v += " and owner_id in (?)"

    Laptop.where(cond_v, people_ids).includes(:status).each { |laptop|
      ret.push({ :serial_number => laptop.serial_number, :uuid => laptop.uuid })
    }

    ret
  end
  
  def update_place_dependencies

    Place.send(:with_exclusive_scope) do

      father  = Place.find_by_id(self.place_id)    
      if father && father.calcAncestorsIds.push(self.place_id).include?(self.id)

        raise _("A child may not be the father nor the father the son.")
      end

      old_me = Place.find_by_id(self.id)
      if self.place_id != old_me.place_id
        self.update_family_tree_registry
        PlaceDependency.update_dependencies(self, father)
      end
    end
  end

  def set_created_at_and_ancestors
    self.created_at = Time.now
    Place.send(:with_exclusive_scope) do
      self.setAncestorsIds
    end
  end

  def unregister_place_dependencies
    Place.send(:with_exclusive_scope) do
      self.unregister_from_ancestors
      PlaceDependency.unregister_dependencies(self)
    end
  end

  def register_place_dependencies
    Place.send(:with_exclusive_scope) do 
      self.register_on_ancestors
      PlaceDependency.register_dependencies(self)
    end
  end

  def getDrillDownInfo
    {
      :object_desc => "Lugar",
      :label => self.name,
      :class_name => self.class.to_s,
      :object_id => self.id
    }
  end

  ###
  # Theres a lot of conflict between the users access
  # to the place objects, so i try to handle it them
  # all together here.
  def self.register(attribs, nodes, register)

    place_parent = Place.find_by_id(attribs[:place_id])
    raise _("No sufficient level of access!") if !(place_parent && register.place.owns(place_parent))

    Place.transaction do

      place = Place.new(attribs)
      if place.save!
        Node.doRegistering(nodes, place.id)
      end
    end
  end
 
  def register_update(attribs, nodes, register)

    raise _("No sufficient level of access!") if !(register.place.owns(self))

    Place.transaction do

      if self.place_id && !attribs[:place_id]
        attribs.delete(:place_id)
      end

      if self.update_attributes(attribs)
        destroy_nodes = Node.where(:place_id => self.id)
        if not nodes.empty?
          destroy_nodes = destroy_nodes.where("nodes.id not in (?)", nodes.map {|n| n["id"]})
        end
        if destroy_nodes.any?
          Node.destroy(destroy_nodes)
        end
        Node.doRegistering(nodes, self.id)
      end
    end
  end

  def self.unregister(places_ids, unregister)

  to_be_destroy_places = Place.find_all_by_id(places_ids)
  to_be_destroy_places.each { |place|
    raise _("No sufficient level of access!") if !(unregister.place.owns(place))
  }

  Place.destroy(to_be_destroy_places)

  end

  ###
  # Optimization functions for fast sub-trees recovery
  #
  def update_family_tree_registry

    old_ancestors_places = self.getAncestorsPlaces
    self.unregister_from_ancestors
    
    self.register_on_ancestors
    new_ancestors_places = self.getAncestorsPlaces

    ex_ancestors_places = old_ancestors_places - new_ancestors_places
    newest_ancestors_places = new_ancestors_places - old_ancestors_places
    my_descendants_places = self.getDescendantsPlaces

    ex_ancestors_ids = ex_ancestors_places.map { |ex| ex.id }
    newest_ancestors_ids = newest_ancestors_places.map { |newest| newest.id }
    my_descendants_ids = self.getDescendantsIds

    ex_ancestors_places.each { |ex_ancestor_place|
      ex_ancestor_place.removeDescendantsIds(my_descendants_ids+[self.id])
      ex_ancestor_place.save!
    }

    #raise ex_ancestors_ids.to_s + "::" + newest_ancestors_ids.to_s + "::" + my_descendants_ids.to_s
    newest_ancestors_places.each { |newest_ancestor_place|
      newest_ancestor_place.addDescendantsIds(my_descendants_ids)
      newest_ancestor_place.save!
    }

    my_descendants_places.each { |my_descendant_place|
      my_descendant_place.removeAncestorsIds(ex_ancestors_ids)
      my_descendant_place.addAncestorsIds(newest_ancestors_ids)
      my_descendant_place.save!
    }

    true
  end

  def register_on_ancestors

    if !self.ancestors_ids
      self.setAncestorsIds
    end

    self.getAncestorsPlaces.each { |ancestor_place|
      ancestor_place.addDescendantsIds([self.id])
      ancestor_place.save!
    }

    true
  end

  def unregister_from_ancestors

    self.getAncestorsPlaces.each { |ancestor_place|
      ancestor_place.removeDescendantsIds([self.id])
      ancestor_place.save!
    }

    self.ancestors_ids = nil
    true
  end

  def setAncestorsIds(ancestors_ids = nil)

    if !ancestors_ids
      ancestors_ids = self.calcAncestorsIds
    end

    self.ancestors_ids = ancestors_ids.to_json
    true
  end

  def getAncestorsIds
    self.ancestors_ids ? JSON.parse(self.ancestors_ids) : []
  end

  def getAncestorsPlaces
    Place.where(:id => self.getAncestorsIds)
  end

  def addAncestorsIds(new_ancestors_ids)
    old_ancestors_ids = self.getAncestorsIds
    newest_ancestors_ids = old_ancestors_ids + new_ancestors_ids
    self.setAncestorsIds(newest_ancestors_ids)
    true
  end

  def removeAncestorsIds(ex_ancestors_ids)
    old_ancestors_ids = self.getAncestorsIds
    new_ancestors_ids = old_ancestors_ids - ex_ancestors_ids
    self.setAncestorsIds(new_ancestors_ids)
  end

  def setDescendantsIds(descendants_ids = nil)

    if !descendants_ids
      descendants_ids = self.calcDescendantsIds 
    end

    self.descendants_ids = descendants_ids.to_json
    true
  end

  def getDescendantsIds
    self.descendants_ids ? JSON.parse(self.descendants_ids) : []
  end

  def getDescendantsPlaces
    Place.where("id in (?)", self.getDescendantsIds)
  end

  def addDescendantsIds(new_descendants_ids)
    old_descendants_ids = self.getDescendantsIds
    newest_descendants_ids = old_descendants_ids + new_descendants_ids
    self.setDescendantsIds(newest_descendants_ids)
    true
  end

  def removeDescendantsIds(ex_descendants_ids)
    old_descendants_ids = self.getDescendantsIds
    new_descendants_ids = old_descendants_ids - ex_descendants_ids
    self.setDescendantsIds(new_descendants_ids)
    true
  end
  # End of Optimizations
  ###

  ###
  #
  #
  def getPartDistribution()
    ret = Hash.new
    ret[:place_name] = self.name
    performs = Perform.where(:place_id => self.id)

    cnt = performs.joins('LEFT JOIN laptops ON (performs.person_id = laptops.owner_id)').count('laptops.id')
    cnt_assigned = performs.joins('LEFT JOIN laptops ON (performs.person_id = laptops.assignee_id)').count('laptops.id')
    ret[:count] = cnt
    ret[:count_assigned] = cnt_assigned
    ret[:childs] = Array.new
    self.places.each { |p| 
      cInfo = p.getPartDistribution()
      ret[:count] += cInfo[:count]
      ret[:count_assigned] += cInfo[:count_assigned]
      ret[:childs].push(cInfo)
    }
    ret 
  end


  def getTreeDepth(root)
    max = 1
    v = Array.new
    root[:childs].each { |c|
      v.push(getTreeDepth(c))
    }
    max += v.max if v.length > 0
    max
  end


  def buildMatrix(node, matrix, label_column = 0, count_column = 9)
    if node[:count] > 0 or node[:count_assigned] > 0:
      v = Array.new
      v[label_column] = node[:place_name] 
      v[count_column] = node[:count]
      v[count_column + 1] = node[:count_assigned]
      matrix.push(v)
      node[:childs].each { |c| buildMatrix(c, matrix, label_column + 1, count_column) }
    end
    matrix
  end
  
  def getDate()
    self.created_at.to_s
  end

  def getName

    ancestors = self.getAncestorsPlaces
    ancestors.sort! { |a,b|

      a.id == b.place_id ? -1 : b.getAncestorsIds.include?(a.id) ? -1 : 1
    }
    ancestors.push(self).collect(&:name).join(':')
  end

  def getDescription()
    self.description ? self.description : ""
  end

  def getParentPlace()
    self.place ? self.place.getName : ""
  end

  def getType()
    return self.place_type.name if self.place_type
    "Null"
  end

  def calcDescendantsIds
    list = []
    stack = []
    stack += self.places
    while(stack != [])
      father = stack.pop
      list.push(father.id)
      stack += father.places
    end
    list
  end

  ###
  # Get place parents ids.
  def calcAncestorsIds
    parents_ids = []
    place = self
    while (place.place_id != nil)
      parents_ids.push(place.place_id)
      place = place.place
    end
    parents_ids
  end

  ###
  # Generates recursive hash-based representation
  # for the places in the systems for diferents
  # widgets on the GUI.
  def getElementsHash
    place = self
    places = [place]

    while (place.place)
      place = place.place
      places.push(place)
    end

    places.reverse!
    Place.genElementsHash(places)
  end

  def self.genElementsHash(places)
    ret = Hash.new
    place = places.first
    len = places.length
    ret[:id] = place.id
    ret[:text] = place.name
    ret[:elements] = len > 1 ? [Place.genElementsHash(places.slice(1,len-1))] : []
    ret
  end

  def genTreeElements(prune, prefix = "schoolmanager", sep = "+")
    ret = Hash.new
    if prune.include? self.place_type_id
      ret[:label] = self.getName
      ret[:option_name] = "#{prefix}#{sep}#{self.id}"
    else
      ret[:title] = self.getName
      ret[:nodes] = self.places.map { |place| place.genTreeElements(prune) }
    end
    ret
  end

  ###
  #  All functions for Google map qooxdoo widget.
  #

  def getMapNodes(node_type_ids = [])
    nodes = self.nodes
    if node_type_ids != []
      nodes = nodes.where(:node_type_id => node_type_ids)
    end
    nodes.map { |node| 
      node.nodefize
    }
  end

  def getSubMapNodes(node_type_ids = [])
    ret = self.getMapNodes(node_type_ids)
    self.places.each { |place|
      ret+= place.getSubMapNodes(node_type_ids)
    }
    ret
  end

  # TODO: Needs performance boots.
  def getMapCenter(subNodes = false)

    retNode = nil

    self.nodes.each { |node|
      retNode = node
      return retNode if node.node_type.internal_tag == "center"
    }

    if subNodes
      subNode = nil
      self.places.each { |place|
        subNode = place.getMapCenter(true)
        break if subNode
      }
      retNode = subNode if !retNode
    end

    retNode
  end

  def getMap(subNodes = false)
    description = Hash.new
    center = self.getMapCenter(subNodes)
    if center
      description["center"] = { "lat" => center.getLat, "lng" => center.getLng() }
      description["zoom"] = center.getZoom()
      description["nodes"] = subNodes ? self.getSubMapNodes() : self.getMapNodes()
    else
      description = Place.defaultMap()
    end
    description
  end

  def self.defaultMap()
    description = Hash.new
    description["center"] = { "lat" => "-25.26666667", "lng" => "-57.666667" }
    description["zoom"] = 1
    description["nodes"] = []
    description
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)
    scope = includes(:ancestor_dependencies)
    scope = scope.where("place_dependencies.ancestor_id in (?)", places_ids)
    Place.with_scope(scope) do
      yield
    end
  end

  def self.roots4(query, current_user)
    person = current_user.person
    query = query.includes(:performs)
    query = query.where('performs.person_id' => person.id, 'performs.profile_id' => person.profile.id)
    query
  end

  ###
  # tch says: Should this die already?
  def self.theSwissArmyKnifeFuntion(city_id, schoolInfo = nil, shiftInfo = nil, gradeInfo = nil, sectionInfo = nil)

    # Select id from places as p1, places as p2, places as p3, places as p4 where (p1.place_id = p2.id and p2.place_id = p3.id and 
    # p3.place_id = p4.id ) and (p4.name = schoolInfo and p3.name = shiftInfo and p2.name = gradeInfo and p1.sectionInfo);
    ret = nil

    Place.transaction do
      school_type_id = PlaceType.find_by_internal_tag("school").id
      shift_type_id = PlaceType.find_by_internal_tag("shift").id
      grade_type = PlaceType.find_by_internal_tag(gradeInfo)
      section_type_id = PlaceType.find_by_internal_tag("section").id

      school = Place.find_by_name_and_place_type_id_and_place_id(schoolInfo, school_type_id, city_id)
      if !school
        school = Place.new({:name => schoolInfo, :place_type_id => school_type_id, :place_id => city_id})
        school.save!
      end
      ret = school

      if shiftInfo != nil
        shift = Place.find_by_name_and_place_type_id_and_place_id(shiftInfo, shift_type_id, ret.id)
        if !shift
          shift = Place.new({ :name => shiftInfo, :place_type_id => shift_type_id, :place_id => ret.id })
          shift.save!
        end
        ret = shift
      end

      if gradeInfo != nil
        grade = Place.find_by_name_and_place_type_id_and_place_id(grade_type.name, grade_type.id, ret.id)
        if !grade
          grade = Place.new({ :name => grade_type.name, :place_type_id => grade_type.id, :place_id => ret.id})
          grade.save!
        end
        ret = grade
      end

      if sectionInfo != nil
        section = Place.find_by_name_and_place_type_id_and_place_id(sectionInfo, section_type_id, ret.id)
        if !section
          section = Place.new({ :name => sectionInfo, :place_type_id => section_type_id, :place_id => ret.id})
          section.save!
        end
        ret = section
       end

    end
    ret
  end

  def getProblemReports(which = nil) 
    ret = ProblemReport.where(:place_id => self.getDescendantsIds.push(self.id))
    
    if which:
        ret = ret.where(:solved => (which != :open))
    end

    ret.length
  end

  def getLaptopSerials
   laptops = Laptop.includes(:owner => :performs)
   laptops = laptops.where("performs.place_id in (?)", self.getDescendantsIds.push(self.id))
   laptops.map { |laptop| laptop.getSerialNumber }
  end

  ###
  #  We define a simple order relationship between places
  def self.highest(places)
    places.sort { |a,b| a.getAncestorsIds.length > b.getAncestorsIds.length ? -1 : 1 }.pop
  end

  ###
  #  There are many cases where is needed only the roots places from 
  #  a set of places.
  # TODO: Doing it in one query, using place_dependencies table
  def self.roots(places)

    "select count(*), descendant_id from place_dependencies group by descendant_id order by count(*) ASC;"
    roots = []
    places_ids = places.collect(&:id)
    places.each { |root_candidate|

      descendants_ids = places_ids - [root_candidate.id]
      ancestors_ids = root_candidate.getAncestorsIds #root_candidate.ancestors.collect(&:id) - [root_candidate.id]

      roots.push(root_candidate) if (ancestors_ids - descendants_ids) == ancestors_ids && !roots.include?(root_candidate)
    }

    roots
  end

  ###
  #  A place owns another when its parent
  def owns(place)
    return true if self.getDescendantsIds.push(self.id).include?(place.id)
  end

  def performing_people
    people = Person.includes(:performs => :place)
    places_ids = self.getDescendantsIds.push(self.id)
	people.where(:id => places_ids)
  end

  ###
  # Sort places, WARNING: only for upper sub-tree hierarchies
  def self.sort(places)
    places.sort { |a,b|

      a.id == b.place_id ? -1 : b.getAncestorsIds.include?(a.id) ? -1 : 1
    }
  end

end
