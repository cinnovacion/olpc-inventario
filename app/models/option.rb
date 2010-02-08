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
                                                                          
class Option < ActiveRecord::Base
  belongs_to :question

  def self.register(question_id, options)
    Option.transaction do
      options.each { |option_def|
         attribs = Option.unoptionifize(question_id, option_def)
         Option.create!(attribs)
      }
    end
    true
  end

  def self.register_update(question_id, options)
    Option.transaction do

      cond_purge = ["question_id = ? and id not in (?)",question_id, options.map {|o| o["id"] }.push(-1) ]
      to_destroy_options = Option.find(:all, :conditions => cond_purge)
      Option.destroy(to_destroy_options)

      options.each { |option_def|
        attribs = Option.unoptionifize(question_id, option_def)
        option = Option.find_by_id(option_def["id"])
        if !option
          option = Option.new(attribs)
        else
          option.update_attributes(attribs)
        end
        option.save!
      }
    end
    true
  end

  def self.unoptionifize(question_id, option_def)
    attribs = Hash.new
    attribs[:option] = option_def["text"]
    attribs[:correct] = option_def["checked"] ? true : false
    attribs[:question_id] = question_id
    attribs
  end

end
