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

require 'fecha'
                                                                          
class PeopleController < SearchController
  skip_filter :rpc_block, :only => [ :show, :update, :requestStudents ]

  LAPTOPS_LIMIT = 5

  def initialize
    super(:includes => :profiles)
  end

  def new
    
    if params[:id]
      p = Person.find(params[:id])
      @output["id"] = p.id
    else
      p = nil
    end
    
    @output["fields"] = []
    @output["with_tabs"] = true

    h = { "label" => _("Name"),"datatype" => "textfield" }.merge( p ? {"value" => p.name } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Lastname"),"datatype" => "textfield" }.merge( p ? {"value" => p.lastname } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Document ID"),"datatype" => "textfield" }.merge( p ? {"value" => p.id_document } : {} )
    @output["fields"].push(h)

    fecha = p && p.birth_date ? Fecha::pyDate(p.birth_date.to_s) : ""
    h = { "label" => _("Birth date"),"datatype" => "date",  :value => fecha  }
    @output["fields"].push(h)

    h = { "label" => _("Phone num."),"datatype" => "textfield" }.merge( p ? {"value" => p.phone } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Cell num."),"datatype" => "textfield" }.merge( p ? {"value" => p.cell_phone } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Email"),"datatype" => "textfield" }.merge( p ? {"value" => p.email } : {} )
    @output["fields"].push(h)

    if p and p.image
      path = "/images/view/#{p.image.id}"
      h = { "label" => _("Image"),"datatype" => "image", "value" => path }
      @output["fields"].push(h)
    end

    h = { "label" => _("Notes"), "datatype" => "textarea" }.merge( p ? {"value" => p.notes } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Personal image"), "datatype" => "uploadfield", :field_name => :fotocarnet }
    @output["fields"].push(h)

    profiles = buildSelectHash2(Profile, -1, "getDescription()", false, [ "access_level < ?", current_user.person.profile.access_level])

    h = { "datatype" => "tab_break", "title" => _("Roles") }
    @output["fields"].push(h)

    ###Dynamic Table for Performs
    options = Array.new
   
    dataGrid = Perform.find_all_by_person_id(p.id).map { |perform|
      [
       { :value => perform.place_id, :text => perform.place.getName },
       { :value => perform.profile_id, :text => perform.profile.getDescription }
      ]
    } if p

    h = { "label" => "Place", "datatype" => "hierarchy_on_demand", "options" => { "width" => 360, "height" => 120 }, :hash_data_tag => "place_id"}
    options.push(h)

    h = { "label" => "Profile", "datatype" => "combobox", "options" => profiles, :hash_data_tag => "profile_id" }
    options.push(h)

    h = {"label" => "", "datatype" => "dyntable", :widths => [320,160], "options" => options}
    h.merge!( p ? {"data" => dataGrid } : {} )
    @output["fields"].push(h)

    if p
      assigned = Laptop.where(:assignee_id => p.id)
      assigned_count = assigned.count
      assigned = assigned.limit(LAPTOPS_LIMIT)
      in_hands = Laptop.where(:owner_id => p.id)
      in_hands_count = in_hands.count
      in_hands = in_hands.limit(LAPTOPS_LIMIT)
    else
      assigned = []
      assigned_count = 0
      in_hands = []
      in_hands_count = 0
    end

    if assigned.any? or in_hands.any?
      h = { "datatype" => "tab_break", "title" => _("Laptops") }
      @output["fields"].push(h)
    end

    assigned.each { |laptop|
      h = { "label" => _("Laptop assigned:"), :datatype => "abmform_details", :option => "laptops", :id => laptop.id, :text => laptop.serial_number }
      @output["fields"].push(h)
    }

    if assigned_count > LAPTOPS_LIMIT
      extra = assigned_count - LAPTOPS_LIMIT
      h = { :datatype => "label", :text => _("%d more laptops not shown") % extra }
      @output["fields"].push(h)
    end

    in_hands.each { |laptop|
      h = { "label" => _("Laptop in hands:"), :datatype => "abmform_details", :option => "laptops", :id => laptop.id, :text => laptop.serial_number }
      @output["fields"].push(h)
    }

    if in_hands_count > LAPTOPS_LIMIT
      extra = in_hands_count - LAPTOPS_LIMIT
      h = { :datatype => "label", :text => _("%d more laptops not shown") % extra }
      @output["fields"].push(h)
    end

   ###end

    # DrillDown Info
    #
    # FIXME: this has to be implemented: the ability to navigate through related objects. 
    #
    
#     assoc_objs = p ? p.associatedObjs : []
#     if assoc_objs.length > 0
#       h = { "datatype" => "tab_break", "title" => "Objetos Relacionados" }
#       @output["fields"].push(h)
# 
#       h = { "datatype" => "drilldown_info", "value" => assoc_objs }
#       @output["fields"].push(h)
#     end


  end
	
  def save
    datos = JSON.parse(params[:payload])
    attribs = Hash.new

    data_fields = datos["fields"].reverse
 
    attribs[:name] = data_fields.pop
    attribs[:lastname] = data_fields.pop
    attribs[:id_document] = data_fields.pop
    attribs[:birth_date] = data_fields.pop
    attribs[:phone] = data_fields.pop
    attribs[:cell_phone] = data_fields.pop
    attribs[:email] = data_fields.pop    
    attribs[:notes] = data_fields.pop.strip
    performs = data_fields.pop.map { |perform| [ perform["place_id"], perform["profile_id"] ]  }

    if datos["id"]
      p = Person.find datos["id"]
      p.register_update(attribs, performs, params[:fotocarnet], current_user.person)
    else
      Person.register(attribs, performs, params[:fotocarnet], current_user.person, nil)
    end
 
    @output["msg"] = datos["id"] ? _("Changes saved.") : _("Person added.")  
  end

  def delete
    people_ids = JSON.parse(params[:payload])
    Person.unregister(people_ids, current_user.person)
    @output["msg"] = _("Elements deleted.")
  end

  def listPeople
    place_id = params["id"]
    list = []

    if place_id
      people = Person.includes(:performs)
      people = people.where("performs.place_id = ?", place_id)
      list = people.order("people.lastname, people.name").map { |student|
        h = Hash.new
        h[:id] = student.id
        h[:text] = student.getFullName
        h
      }
    end
    @output[:list] = list
  end

  def movePeople
    datos = JSON.parse(params[:payload])
    src_place_id = datos["src_place_id"]
    dst_place_id = datos["dst_place_id"]
    add_comment = datos["add_comment"]

    people_ids = datos["people_ids"]
    if src_place_id.nil? or dst_place_id.nil? or people_ids.nil?
      raise _("Missing field data.");
    end

    src_place = Place.find_by_id(src_place_id)
    dst_place = Place.find_by_id(dst_place_id)
    raise _("Could not find place.") if src_place.nil? or dst_place.nil?

    Perform.transaction do
      people_ids.each { |person_id|
        perform = Perform
        perform = perform.includes(:person) if add_comment
        perform = perform.where(:person_id => person_id, :place_id => src_place.id).first
        next if perform.nil?

        if !Perform.alreadyExists?(person_id, dst_place_id, perform.profile_id)
          Perform.create!({:person_id => person_id, :place_id => dst_place_id, :profile_id => perform.profile_id})
        end
        Perform.delete(perform.id)

        if add_comment
          person = perform.person
          time = Time.now.strftime("%d/%m/%Y")
          moved_by = current_user.getPersonName()
          old_place = src_place.getName
          new_place = dst_place.getName
          comment = _("#{time}: Person was moved from #{old_place} to #{new_place} by #{moved_by}")
          if person.notes and person.notes != ""
            comment = person.notes + "\n" + comment
          end
          person.notes = comment
          person.save!
        end
      }
    end

    @output[:msg] = _("People moved.")
  end

  ##
  # REST accessable methods.
  def show
    person = Person.find_by_id(params["id"])
    render :xml => person.to_xml
  end

  def update
    person = Person.find_by_id(params["id"])
    person.update_attributes(params[:person])
    render :xml => person.to_xml, :status => :ok
  end

  def requestStudents

   ret = { :list => [] }
   place_id =  params["id"]

   if place_id
     people = Person.includes(:performs => :profile)
     people = people.where("performs.place_id = ? and profiles.internal_tag = 'student'", place_id)
     ret[:list] = people.map { |student|
       h = Hash.new
       h[:id] = student.id
       h[:text] = student.getFullName
       h
     }
   end
   render :xml => ret.to_xml    
  end
  # END of REST
  ##

  ##
  # Methods for Dynamic Delivery Form.
  def peopleAmount
    place_id = params[:place_id].to_i
    with_filter = (params[:withFilter] == "true")
    assignation_mode = (params[:mode] == "assignment")

    performs = Perform.where(:place_id => place_id)

    if assignation_mode
      performs = performs.includes(:person => :laptops_assigned)
    else
      performs = performs.includes(:person => :laptops)
    end

    amount = 0
    performs.each { |perform|
      person = perform.person
      if assignation_mode
        laptops = person.laptops_assigned
      else
        laptops = person.laptops
      end
      amount += 1 if (laptops == []) == with_filter or not with_filter
    }
    @output["amount"] = amount

  end #
  #####

  # produce a list of (SN,name of person) for people in a specific place
  # who have laptops assigned but not in their hands
  # used by DynamicDeliveryForm
  def laptopsNotInHands
    place_id = params[:place_id].to_i
    performs = Perform.includes(:person => :laptops_assigned, :person => :laptops)
    performs = performs.where(:place_id => place_id).order("people.lastname")
    result = Array.new()

    performs.each { |perform|
      person = perform.person
      laptops_assigned = person.laptops_assigned.map { |l| l.serial_number }
      laptops = person.laptops.map { |l| l.serial_number }
      laptops_not_in_hands = laptops_assigned - laptops
      laptops_not_in_hands.each { |laptop|
        result.push([laptop, person.getFullName()])
      }
    }
    @output["items"] = result
    p result
  end #

end
