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
                                                                        
class SectionDetail < ActiveRecord::Base
  has_many :laptop_details
  belongs_to :lot
  belongs_to :place

  attr_accessible :lot, :lot_id, :place, :place_id

  def self.alreadyExists?(lot_id, place_id)
    return true if SectionDetail.find_by_lot_id_and_place_id(lot_id, place_id)
    false
  end

  def self.register(attribs)

    student_profile_id = Profile.find_by_internal_tag("student").id
    SectionDetail.transaction do
      sectionDetail = SectionDetail.new(attribs)
      if sectionDetail.save!
        cond_v = ["place_id in (?) and profile_id in (?)", sectionDetail.place_id, student_profile_id ]
        Perform.find(:all, :conditions => cond_v).each { |perform|
          person = perform.person
          laptop_id = person.laptops.first ? person.laptops.first.id : nil
          LaptopDetail.create!({ :section_detail_id => sectionDetail.id, :person_id => person.id, :laptop_id => laptop_id })
        }
      end
    end

  end

  def self.register_die(sectionDetail)
    sectionDetail.laptop_details.each { |laptopDetail|
      LaptopDetail.destroy(laptopDetail)
    }
    SectionDetail.destroy(sectionDetail)
  end

end
