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
                                                                     
class QuizzesController < SearchController
  attr_accessor :include_str

  def initialize
    super 
    @include_str = [:person, :questions]
  end

  def search
    do_search(Quiz,{ :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(Quiz)
    do_search(Quiz,{ :include => @include_str })
  end

  def new

    @output["fields"] = []
    if params[:id]
      quiz = Quiz.find(params[:id])
      @output["id"] = quiz.id
    else
      quiz = nil
    end

    @output["window_title"] = "Crear nueva evaluación"

    @output["first_tab_title"] = "Preguntas" 

    h = { "label" => "Titulo", "datatype" => "textfield" }.merge( quiz ? {"value" => quiz.title } : {} )
    @output["fields"].push(h)

    id = quiz ? quiz.person_id : -1
    people = buildSelectHashSingle(Person, id, "getFullName()")
    h = { "label" => "Autor", "datatype" => "select", "options" => people, :option => "personas", "vista" => Person::SELECTION_VIEW }
    @output["fields"].push(h)

    questions = quiz ? quiz.questionifize : []
    h = { "label" => "Preguntas", "datatype" => "multiple_choice_form_maker", "questions" => questions }
    @output["fields"].push(h)

    h = { "datatype" => "tab_break", "title" => "Evaluados" }
    @output["fields"].push(h)

    ###Dynamic Table
    options = Array.new

    data = quiz ? quiz.answers.map { |answer| [{ :value => answer.person_id, :text => answer.person.getFullName() }] } : []

    h = { "label" => "Personas", "datatype" => "select", "select_name" => "personas" }
    options.push(h)

    h = {"label" => "", "datatype" => "dyntable", :widths => [320], "options" => options}.merge( quiz ? {"data" => data } : {} )
    @output["fields"].push(h)
    ###END

  end

  def save
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse
    attribs = Hash.new

    attribs[:title] = data_fields.pop
    attribs[:person_id] = data_fields.pop
    questions = data_fields.pop
    people_ids = data_fields.pop.map { |p| p["Personas"].to_i }

    if datos["id"]
      quiz = Quiz.find_by_id(datos["id"])
      quiz.register_update(attribs, questions, people_ids)
    else
      Quiz.register(attribs, questions, people_ids)
    end

    @output["msg"] = datos["id"] ? "Datos Actualizados" : "Datos creados"
  end

  def delete
    id = JSON.parse(params[:payload])
    Quiz.unregister(id)
    @output["msg"] = "Elementos eliminados"
  end

end
