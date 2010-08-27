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
                                                                  
class SchoolsController < ApplicationController
  around_filter :rpc_block

  def general_info
    school_id = params[:id]

    info = Array.new

    school = Place.find_by_id(school_id)

    info.push({ :label => _("General info of the school"), :data => "" })
    info.push({:label => _("Number"), :data => school.name })
    info.push({ :label => _("Name"), :data => school.getDescription })

    student_profile_id = Profile.find_by_internal_tag("student").id
    teacher_profile_id = Profile.find_by_internal_tag("teacher").id
    director_profile_id = Profile.find_by_internal_tag("director").id

    length = Perform.peopleFromAs(school_id, true, [student_profile_id]).length
    info.push({ :label => _("Number of students"), :data => length })

    length = Perform.peopleFromAs(school_id, true, [teacher_profile_id]).length
    info.push({ :label => _("Number of teachers"), :data => length })

    info.push({ :label => _("Principals"), :data => "" })
    inc = [:person,:profile]
    cond = ["performs.place_id = ? and profiles.id = ?", school_id, director_profile_id]
    Perform.find(:all, :include => inc, :conditions => cond).each { |member|
      info.push({ :label => member.person.getFullName, :data => member.person.getPhone })
    }

    #
    # FIXME: please write a comment about the following block of code or otherwise remove it. 
    #

    #info.push({ :label => "Servidores de la Escuela", :data => "" })
    #cond = ["school_infos.place_id = ?", school_id]
    #SchoolInfo.find(:all, :conditions => cond).each { |server|
    #info.push({ :label => "", :data => server.getHostname })
    #}

    @output[:info] = info
  end

  def createPlace
    parent_place_id = params[:parent_place_id]
    place_type_tag = params[:place_type]
    place_name = params[:place_name]

    if parent_place_id && place_type_tag && place_name
      place_type = PlaceType.find_by_internal_tag(place_type_tag)
      if place_type

        attribs = Hash.new
        attribs[:name] = place_name
        attribs[:place_type_id] = place_type.id
        attribs[:place_id] = getId(parent_place_id)

        Place.register(attribs, [], current_user.person)
        @output["msg"] = _("Place added.")  
      else
        raise _("The data provided is not correct.")
      end
    end

  end

  def deletePlace
    to_delete_place_id = params[:id]
    begin
      Place.unregister([to_delete_place_id], current_user.person)
      @output["msg"] = "Place deleted."
    rescue
      raise _("Can't delete the place (it probably has dependencies).")
    end
  end

  def createPerson

    begin
      place_id = params[:place_id].to_i
      name = params[:name].to_s
      lastname = params[:lastname].to_s
      id_document = params[:id_document].to_s
      type = params[:type].to_s

      place = Place.find_by_id(place_id)
      profile = Profile.find_by_internal_tag(type)

      if place && profile
        attribs = Hash.new
        attribs[:name] = name
        attribs[:lastname] = lastname
        attribs[:id_document] = id_document
        performs = [[place.id, profile.id]]
        Person.register(attribs, performs, "", current_user.person, nil)
        
        @output["msg"] = _("Person registered.") 
      else
        raise _("The data provided is not correct.")
      end 

    rescue
      raise _("Couldn't great the person.")
    end
  end

  def deletePerson
    begin
      Person.unregister([params[:id].to_i], current_user.person)     
    rescue
      raise _("This person can't be deleted.")
    end
  end

  def updatePerson
    person = Person.find_by_id(params[:id])
    name = params[:name]
    lastname = params[:lastname]
    id_document = params[:id_document]

    attribs = Hash.new
    attribs[:name] = name if (name and name != "")
    attribs[:lastname] = lastname if (lastname and lastname != "")
    attribs[:id_document] = id_document if (id_document and id_document != "")

    if attribs.keys.length > 0
      person.update_attributes(attribs)
    else
      raise _("Can't update this person.")
    end
  end

end
