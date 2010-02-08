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
                                                                         
class Quiz < ActiveRecord::Base
  belongs_to :person
  has_many :questions
  has_many :answers

  def self.getColumnas()
    [ 
     {:name => "Id", :key => "quizzes.id", :related_attribute => "id", :width => 50},
     {:name => "Titulo", :key => "quizzes.title", :related_attribute => "getTitle()", :width => 255},
     {:name => "Fecha", :key => "quizzes.created_at", :related_attribute => "getCreatedAt()", :width => 100},
     {:name => "Autor", :key => "people.name", :related_attribute => "getAuthor()", :width => 100},
     {:name => "CI", :key => "people.document_id", :related_attribute => "getAuthorIdDoc()", :width => 100}
    ]
  end

  def self.register(attribs, questions = [], people_ids = [])
    Quiz.transaction do
      quiz = Quiz.new(attribs)
      if quiz.save!
        Question.register(quiz.id, questions)
        Answer.register(quiz.id, people_ids)
      end  
    end
   true
  end

  def register_update(attribs, questions= [], people_ids = [])
    Quiz.transaction do
      if self.update_attributes!(attribs)
        Question.register_update(self.id, questions)
        Answer.register_update(self.id, people_ids)
      end
    end
    true
  end

  def self.unregister(quiz_id)
    Quiz.transaction do
      quiz = Quiz.find_by_id(quiz_id)

      quiz.answers.each {|answer|
        answer.choices.destroy(answer.choices)
        Answer.destroy(answer)
      }

      quiz.questions.each { |question|
        question.options.destroy(question.options)
        Question.destroy(question) 
      }
      Quiz.destroy(quiz)
    end
    true
  end

  def before_create
    self.created_at = Time.now
  end

  def getTitle
    self.title ? self.title : ""
  end

  def getCreatedAt
    self.created_at ? self.created_at : ""
  end

  def getAuthor
    self.person_id ? self.person.getFullName() : ""
  end

  def getAuthorIdDoc
    self.person_id ? self.person.getIdDoc() : ""
  end

  def questionifize
    self.questions.map { |question|
      qHash =Hash.new
      qHash[:id] = question.id
      qHash[:text] = question.question
      qHash[:options] = question.options.map { |option|
        {
         :id => option.id, 
         :text => option.option, 
         :checked => option.correct ? true : false 
        }
      }
      qHash
    }
  end

end
