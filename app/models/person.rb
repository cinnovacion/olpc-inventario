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
                                                                      
class Person < ActiveRecord::Base

  acts_as_audited

  belongs_to :image
  has_many :laptops, :class_name => "Laptop", :foreign_key => :owner_id
  has_many :laptops_assigned, :class_name => "Laptop", :foreign_key => :assignee_id
  has_many :responsible_movements, :class_name => "Movement", :foreign_key => :responsible_person_id
  has_many :source_movements, :class_name => "Movement", :foreign_key => :source_person_id
  has_many :destination_movements, :class_name => "Movement", :foreign_key => :destination_person_id
  has_many :performs
  has_many :profiles, :through => :performs, :source => :profile
  has_many :notification_subscribers
  has_one :user

  validates_uniqueness_of :id_document, :message => _("Repeated document id number")
  validates_presence_of :id_document, :message => _("Must have a document id number")


  include DrillDown 

  SELECTION_VIEW = "selection"
  BARCODE_UPPERBOUND = 9999999999

  ###
  # Listado
  #
  def self.getColumnas(vista = "")
    ret = Hash.new

    case vista 
    when Person::SELECTION_VIEW 
      ret.merge!(self.getSelectionCols())
    else
      ret.merge!(self.getDefaultCols())
    end

    ret
  end

  def self.getDefaultCols()
    ret = Hash.new
    ret[:columnas] = [ 
                      {:name => _("Id"),:key => "people.id",:related_attribute => "id", :width => 50},
                      {:name => _("Created at"),:key => "people.created_at",
                        :related_attribute => "getDate()", :width => 120},
                      {:name => _("Name"),:key => "people.name",:related_attribute => "getName()", :width => 110},
                      {:name => _("Last name"),:key => "people.lastname", :related_attribute => "getLastName()", :width => 110}, 
                      {:name => _("Doc. Id."),:key => "people.id_document", :related_attribute => "getIdDoc()", 
                        :width => 100, :selected => true },
                      {:name => _("Doc. ID. Created at"),:key => "people.id_document_created_at", :related_attribute => "getIdDocCreatedAt()", :width => 70}, 
                      {:name => _("Birth Date"),:key => "people.birth_date", :related_attribute => "getBirthDate()",
                        :width => 100},                 
                      {:name => _("Tel."),:key => "people.phone", :related_attribute => "getPhone()", :width => 80},
                      {:name => _("Cell."),:key => "people.cell_phone", :related_attribute => "getCell()", :width => 80},
                      {:name => _("Email"),:key => "people.email", :related_attribute => "getEmail()", :width => 100},
                      {:name => _("Profiles"), :key => "profiles.description", :related_attribute => "getProfiles()", :width => 250},
                      {:name => _("Bar Code"), :key => "people.barcode", :related_attribute => "getBarcode()", :width => 250}
                     ]

    ret[:columnas_visibles] = [true, true, true, true, true, false, false, false, false, false, true, false]
    ret
  end

  def self.getSelectionCols()
    ret = Hash.new
    ret[:columnas] = [ 
                      {:name => _("Id"),:key => "people.id",:related_attribute => "id", :width => 50},
                      {:name => _("Name"),:key => "people.name",:related_attribute => "getName()", :width => 110},
                      {:name => _("Last name"),:key => "people.lastname", :related_attribute => "getLastName()", :width => 110}, 
                      {:name => _("Email"),:key => "people.email", :related_attribute => "getEmail()", :width => 100}
                     ]
    ret[:columnas_visibles] = [false, true, true, true]
    ret
  end

  def self.genAsFromCondition(vista)
    split = vista.split("_")
    
    profile = Profile.find_by_internal_tag(split[0])
    profile_ids = profile ? [profile.id] : []
    
    [ "people.id in (?)",Perform.peopleFromAs(split[1].to_i, true, profile_ids) ]
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new

    case vista
    when ""
      ret["desc_col"] = {:columnas => [2,3],:separator => " "}
      ret["id_col"] = 0
    when "movements", "assignments"
      ret["desc_col"] = 4
      ret["id_col"] = 0
    else
      ret["desc_col"] = 2
      ret["id_col"] = 0
    end

    ret
  end

  def self.register(attribs, performs = [], fotocarnet = "", register = nil)

    #Checking rules for performs
    raise _("Invalid Profile Configuration!") if !Perform.check(register, performs)

    Person.transaction do

      person = Person.new(attribs)
      person.registerFotocarnet(fotocarnet)

      if person.save!

       #Adding Performs.
        performs.each { |perform|
          Perform.create!({:person_id => person.id, :place_id => perform[0].to_i, :profile_id => perform[1].to_i})
        }

      end
    end
  end

  def register_update(attribs, performs = [], fotocarnet = "", register = nil)

    #Checking for person ownership
    raise _("No sufficient level of access") if !(register.owns(self))

    #Checking rules for performs
    raise _("Profile Configuration overrides!") if !Perform.check(register, performs)

    Person.transaction do

      self.registerFotocarnet(fotocarnet)

      if self.update_attributes!(attribs)

       #Updating Performs.
        self.performs.each { |perform|
          Perform.delete(perform.id) if !performs.include?([perform.place_id.to_s, perform.profile_id.to_s])
        }
        performs.each { |perform|
          if !Perform.alreadyExists?(self.id, perform[0].to_i, perform[1].to_i)
            Perform.create!({:person_id => self.id, :place_id => perform[0].to_i, :profile_id => perform[1].to_i})
          end
        }

      end
    end

  end

  def self.unregister(people_ids, unregister)

    cond = ["people.id in (?)", people_ids]
    to_be_destroy_people = Person.find(:all, :conditions => cond)

    to_be_destroy_people.each { |person|
      raise _("No sufficient privileges") if !(unregister.owns(person))
    }

    Person.transaction do
      Perform.transaction do
        Person.send(:with_exclusive_scope) do
          to_be_destroy_people.each { |person|
            Perform.destroy(person.performs)
            Person.destroy(person)
          }
        end
      end
    end

  end

  def registerFotocarnet(fotocarnet)
    if fotocarnet.to_s != ""
      if self.image
        self.image.register_update(fotocarnet)
      else
        self.image_id = Image.register(fotocarnet).id
      end
    end
  end

  def before_save
    old_self = Person.find_by_id(self.id)
    self.id_document_created_at = Date.today if (!old_self || (old_self && !old_self.hasValidIdDoc?)) && self.hasValidIdDoc?
    self.generateBarCode if !self.barcode
  end

  def before_create
    self.created_at = Time.now
  end

  def getDate()
    self.created_at.to_s
  end

  def getFullName()
    self.name and self.lastname ? self.name.to_s + " " + self.lastname.to_s : ""
  end


  def getName()
    self.name
  end

  def getLastName()
    self.lastname
  end

  def getIdDoc()
    self.id_document ? self.id_document : ""
  end
    

  def getBirthDate()
    self.birth_date
  end


  def getPhone()
    self.phone
  end

  def getCell()
    self.cell_phone
  end

  def getEmail()
    self.email ? self.email : ""
  end


  def getPlaceDesc() 
    self.place.getName()
  end

  def getIdDocCreatedAt()
    self.id_document_created_at ? self.id_document_created_at.to_s : ""
  end

  ###
  #
  def isEmailValid?()
    ret = false
    emailRegEx = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    ret = true if self.email && emailRegEx.match(self.email)
    ret
  end


  ###
  #  Gets all the person profiles
  def getProfiles
    self.profiles.collect(&:description).join(',')
  end

  ###
  # Data Scope:
  # User with data scope can only access objects that are related to his
  # performing places and sub-places.
  def self.setScope(places_ids)
    find_include = [:performs => {:place => :ancestor_dependencies}]
    find_conditions = ["place_dependencies.ancestor_id in (?)", places_ids]

    scope = { :find => {:conditions => find_conditions, :include => find_include } }
    Person.with_scope(scope) do
      yield
    end
  end

  ###
  #  It gets rid of common typing error.
  def self.cedulaCleaner!(id_document)
    id_document.gsub!(/,| /,'')
    person = Person.find_by_id_document(id_document)
    return id_document if !person
    return id_document+"_"+rand(999999).to_s
  end

  ##
  # Generates a random barcode serial number.
  ##
  def generateBarCode
    while true
      self.barcode = rand(BARCODE_UPPERBOUND).to_s.rjust(10,"0")
      break if !Person.find_by_barcode(self.barcode)
    end
    self.save!	
  end

  def getBarcode
    self.barcode ? self.barcode : ""
  end

  ##
  #Verifies for a not auto-generated document
  #When id document data is not available, system
  #uses "_" and other not valid characters.
  def hasValidIdDoc?
    return true if self.id_document.match("^\\d+$")
    false
  end


  ###
  #  Since the direct relation between people and places will be deprecated
  #  this is a small trick to avoid backwards compatibility problems.
  def place
    Place.highest(self.places)
  end

  def places
    inc = [:performs]
    cond = ["performs.person_id = ?", self.id]
    Place.find(:all, :conditions => cond, :include => inc)
  end

  ###
  #  One person might have many profiles, but only the highest level
  #  is used to decide uppon his user priviledges
  def profile
    Profile.highest(self.profiles)
  end

  ###
  # A Person owns another if...
  def owns(person)
    return true if self.place.owns(person.place) && self.profile.owns(person.profile)
    false
  end

  ###
  # Finds the nearest boss in the upper hierarchy subtree
  def boss
    profile = self.profile
    place = self.place
    higher_places = Place.sort(place.getAncestorsPlaces.push(place))
  
    bosses = []
    higher_places.reverse.each { |higher_place|
      inc = [:performs => [:place, :profile]]
      cond = ["profiles.internal_tag in (?) and places.id = ?", ["root","developer"], higher_place.id]
      bosses = Person.find(:all, :conditions => cond, :include => inc)
      break if bosses != []
    }

    bosses.sort { |a,b| a.profile.access_level > b.profile.access_level ? 1 : -1 }.pop
  end

end
