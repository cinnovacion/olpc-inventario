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
                                                                        
class Question < ActiveRecord::Base
  belongs_to :quiz
  has_many :options

  def self.register(quiz_id, questions)
    Question.transaction do
      questions.each { |question_def|
        Question.aNew(quiz_id, question_def)
      }
    end
    true
  end

  def self.register_update(quiz_id, questions)
    Question.transaction do

      include_purge = [:options]
      cond_purge = ["quiz_id = ? and id not in (?)", quiz_id, questions.map { |q| q["id"] }.push(-1) ]
      Question.find(:all, :conditions => cond_purge, :include => include_purge).each { |question|
        Option.destroy(question.options)
        Question.destroy(question)
      }   

      questions.each { |question_def|
        if question_def["id"] == -1
          Question.aNew(quiz_id, question_def)
        else
          Option.register_update(question_def["id"], question_def["options"])
        end
      }
     
    end
    true
  end

  def self.aNew(quiz_id, question_def)
    attribs = Question.unquestionifize(quiz_id, question_def)
    question = Question.new(attribs)
    if question.save!
      Option.register(question.id, question_def["options"])
    end
    question
  end

  def self.unquestionifize(quiz_id, question_def)
    attribs = Hash.new
    attribs["quiz_id"] = quiz_id
    attribs["question"] =  question_def["text"]
    attribs
  end

end
