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
                                                                         
class Answer < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :person
  has_many :choices

  def self.getColumnas()
    [ 
     {:name => "Id", :key => "answers.id", :related_attribute => "id", :width => 50},
     {:name => "Questionario", :key => "quizzes.title", :related_attribute => "getQuizTitle()", :width => 254},
     {:name => "Autor", :key => "people.lastname", :related_attribute => "getAutorFullName()", :width => 254},
     {:name => "Creado el", :key => "answers.created_at", :related_attribute => "getCreatedAt()", :width => 254},
     {:name => "Contestado el", :key => "quizzes.answered_at", :related_attribute => "getAnsweredAt()", :width => 254}
    ]
  end

  def self.register(quiz_id, people_ids)
    Answer.transaction do
      people_ids.each { |person_id|
        Answer.aNew(quiz_id, person_id)
      }
    end
    true
  end

  def self.register_update(quiz_id, people_ids)
    Answer.transaction do

      include_purge = [:choices]
      cond_purge = ["quiz_id = ? and person_id not in (?)", quiz_id, people_ids ]
      Answer.find(:all, :conditions => cond_purge, :include => include_purge).each { |answer|
        Choice.destroy(answer.choices)
        Answer.destroy(answer)
      }

      cond_find = ["quiz_id = ? and person_id in (?)",quiz_id, people_ids]
      people_ids_old = Answer.find(:all, :conditions => cond_find).map { |answer| answer.person_id }
      people_ids_new = people_ids - people_ids_old
      Answer.register(quiz_id, people_ids_new)

    end
  end

  def self.aNew(quiz_id, person_id)
     attribs = Hash.new
     attribs["quiz_id"] = quiz_id
     attribs["person_id"] = person_id
     attribs["created_at"] = Time.now
     Answer.create!(attribs)
  end

  def getQuizTitle
    self.quiz_id ? self.quiz.getTitle() : ""
  end

  def getAutorFullName
    self.person_id ? self.person.getFullName() : ""
  end

  def getCreatedAt
    self.created_at ? self.created_at : ""
  end

  def getAnsweredAt
    self.answered_at ? self.answered_at : "Nunca"
  end

end
