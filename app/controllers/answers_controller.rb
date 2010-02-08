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
                                                                       
class AnswersController < SearchController

  attr_accessor :include_str

  def initialize
    super 
    @include_str = [:quiz, :person, :choices]
  end

  def search
    do_search(Answer,{ :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Answer)
    do_search(Answer,{ :include => @include_str })
  end

  def new

    @output["fields"] = []
    if params[:id]
      answer = Answer.find(params[:id])
      @output["id"] = answer.id
    else
      answer = nil
    end

    questionary = Array.new
    quiz = answer.quiz 
    quiz.questions.each { |question|

      question_field = Hash.new
      question_field[:question_id] = question.id
      question_field[:question_text] = question.question
      question_field[:cb_options] = []
      question_field[:comment] = ""

      options = question.options
      if options != []

        question_field[:question_type] = "multiple_choice"
        options.map { |option|
          choice = Choice.find(:all, :conditions => ["answer_id = ? and option_id = ?", answer.id, option.id]).first
          question_field[:cb_options].push({ :label => option.option, :cb_name => option.id, :checked => choice ? true : false })
        }

      else
        
        choice = Choice.find(:all, :conditions => ["answer_id = ? and question_id = ?", answer.id, question.id]).first
        question_field[:comment] = choice ? choice.comment : ""
        question_field[:question_type] = "text_field"

      end

      questionary.push(question_field)
    }
    

    h = {"label" => quiz.getTitle, "datatype" => "question_form", "options" => questionary }
    @output["fields"].push(h)

  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"]

    answers = data_fields.pop

    Choice.register(datos["id"], answers)
  end

end
