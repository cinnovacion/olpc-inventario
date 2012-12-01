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
                                                                         
class LaptopDetail < ActiveRecord::Base
  belongs_to :section_detail
  belongs_to :person
  belongs_to :laptop

  attr_accessible :section_detail, :section_detail_id
  attr_accessible :person, :person_id
  attr_accessible :laptop, :laptop_id

  validates_presence_of :person_id, :message => N_("You must provide the student.")
  validates_presence_of :laptop_id, :message => N_("There is a student without laptop.")

  def self.alreadyExists?(section_detail_id, person_id, laptop_id)
    return true if LaptopDetail.find_by_section_detail_id_and_person_id_and_laptop_id(section_detail_id, person_id, laptop_id)
    false
  end

end
