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
                                                                        
class PlaceType < ActiveRecord::Base
  has_many :places

  validates_uniqueness_of :internal_tag, :message => _("The tag must be unique")

  @@grades_list = ["first_grade", "second_grade", "third_grade", "fourth_grade", "fifth_grade", "sixth_grade", "seventh_grade", "eighth_grade","ninth_grade"]

  def self.getColumnas()
    [ 
     {:name => _("Id"), :key => "place_types.id",:related_attribute => "id", :width => 50},
     {:name => _("Location type"), :key => "place_types.name",:related_attribute => "getName()", :width => 250},
     {:name => _("Internal Tag"),:key => "place_types.internal_tag",:related_attribute => "getInternalTag()", :width => 250}
    ]
  end

  def self.getChooseButtonColumns(vista = "")
    ret = Hash.new
    ret["desc_col"] = 1
    ret["id_col"] = 0
    ret
  end

  def getInternalTag()
    self.internal_tag
  end

  def getName()
    self.name.to_s
  end

  def self.getGradeTypes()
    grades = ["kinder","special","first_grade","second_grade","third_grade","fourth_grade","fifth_grade","sixth_grade","seventh_grade", "eighth_grade","ninth_grade"]
    list = []
    PlaceType.find(:all).each { |type|
      list.push(type.id) if grades.include? type.internal_tag
    }
    list
  end

  def self.nextGradeTag(current_grade_tag)
    @@grades_list[@@grades_list.index(current_grade_tag)+1]
  end

  def self.upGradeAll
    current_year = Date.today.year
    up_grade_list = DefaultValue.getJsonValue("up_grades")
    up_grade_list = up_grade_list ? up_grade_list : []

    if up_grade_list.include?(current_year)

      raise _("This script can be run only once a year") 
    else

      up_grade_list.push(current_year)
    end

    inc = [:place_type]
    cond = ["place_types.internal_tag in (?)", @@grades_list]

    Place.transaction do
      Place.find(:all, :conditions => cond, :include => inc).each { |place|
        current_place_type = place.place_type
        next_place_type = PlaceType.find_by_internal_tag(nextGradeTag(current_place_type.internal_tag))

        raise _("Not present to the next grade %s") % current_place_type.internal_tag if !next_place_type

        place.name = next_place_type.name
        place.place_type_id = next_place_type.id
        place.save!
      }
    end

    DefaultValue.setJsonValue("up_grades", up_grade_list)
    true
  end

end
