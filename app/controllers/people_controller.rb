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
                                                                          
class PeopleController < SearchController
  skip_filter :rpc_block, :only => [ :show, :update, :requestStudents ]

  attr_accessor :include_str

  def initialize
    super
    @include_str = [:profiles]
  end

  def search
    do_search(Person,{:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Person)
    do_search(Person, {:include => @include_str })
  end


  def new
    
    if params[:id]
      p = Person.find(params[:id])
      @output["id"] = p.id
    else
      p = nil
    end
    
    @output["fields"] = []

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

    h = { "label" => _("Personal image"), "datatype" => "uploadfield", :field_name => :fotocarnet }
    @output["fields"].push(h)

    profiles = buildSelectHash2(Profile, -1, "getDescription()", false)

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
    performs = data_fields.pop.map { |perform| [ perform["place_id"], perform["profile_id"] ]  }

    if datos["id"]
      p = Person.find datos["id"]
      p.register_update(attribs, performs, params[:fotocarnet], current_user.person)
    else
      Person.register(attribs, performs, params[:fotocarnet], current_user.person)
    end
 
    @output["msg"] = datos["id"] ? _("Changes saved.") : _("Person added.")  
  end

  def delete
    people_ids = JSON.parse(params[:payload])
    Person.unregister(people_ids, current_user.person)
    @output["msg"] = _("Elements deleted.")
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
     inc = [:performs => :profile]
     cond = ["performs.place_id = ? and profiles.internal_tag = ?", place_id,"student"]
     ret[:list] = Person.find(:all, :conditions => cond, :include => inc).map { |student|

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
  def studentsAmount
    place_id = params[:place_id].to_i
    with_filter = (params[:withFilter] == "true")

    student_profile_id = Profile.find_by_internal_tag("student").id

    include_v = [:person => :laptops]
    cond_v = ["place_id = ? and profile_id = ?", place_id, student_profile_id]

    amount = 0
    Perform.find(:all, :conditions => cond_v, :include => include_v).each { |perform|
      person = perform.person
      amount += 1 if (person.laptops == []) == with_filter or not with_filter
    }
    @output["amount"] = amount

  end #
  #####

end
