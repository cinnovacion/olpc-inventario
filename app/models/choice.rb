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
                                                                         
class Choice < ActiveRecord::Base
  belongs_to :answer
  belongs_to :question
  belongs_to :option

  def self.register(answer_id, answers)
    Choice.transaction do

      # Deleting all choices from the last evaluation.
      answer = Answer.find_by_id(answer_id)
      answer.choices.destroy(answer.choices)

      # Adds the new choices depending on wich kind question is.
      answers.each { |answer_def|
        attribs = Hash.new
        attribs[:answer_id] = answer_id
        attribs[:question_id] = answer_def["question_id"]
        if answer_def["question_type"] == "multiple_choice"
          answer_def["values"].each { |option_id|
            attribs["option_id"] = option_id
            Choice.create!(attribs)
          }
        else
          attribs["comment"] = answer_def["values"]
          Choice.create!(attribs)
        end
      }

      answer.answered_at = Time.now
      answer.save!
    end
    true
  end

end
