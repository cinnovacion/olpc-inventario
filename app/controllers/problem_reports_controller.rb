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
                                                                      
class ProblemReportsController < SearchController

  attr_accessor :include_str

  def initialize
    super
    @include_str = [:problem_type, :person, :laptop]
  end

  def search
    do_search(ProblemReport, {:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(ProblemReport)
    do_search(ProblemReport, {:include => @include_str })
  end

  def new
    @output["window_title"] = "Reporte de problemas"

    @output["verify_before_save"] = true
    @output["verify_save_url"] = "/problem_reports/verify_save"

    if params[:id]
      problem_report = ProblemReport.find_by_id(params[:id])
      @output["id"] = problem_report.id
    else
      problem_report = nil
    end

    @output["fields"] = []

    id = problem_report ? problem_report.problem_type_id : -1
    problem_types = buildSelectHash2(ProblemType, id, "getName", false, [])
    h = { "label" => "Problema", "datatype" => "combobox", "options" => problem_types }
    @output["fields"].push(h)

    id = problem_report ? problem_report.laptop_id : -1
    laptop = buildSelectHashSingle(Laptop, id, "getSerialNumber()")
    h = { "label" => "Laptop", "datatype" => "select", "options" => laptop, :option => "laptops", "text_value" => true }
    @output["fields"].push(h)

    yesSelected = problem_report && problem_report.solved ? true : false
    options = buildBooleanSelectHash(yesSelected) 
    h = {"label" => "Solucionado?", "datatype" => "combobox", "options" => options}
    @output["fields"].push(h)

    comment = problem_report ? problem_report.getComment : ""
    h = { "label" => "Comentarios", "datatype" => "textarea","width" => 250, "height" => 50, :value => comment }
    @output["fields"].push(h)

  end

  def verify_save

    str = ""
    attribs = getData()

    owner_name = "Nadie"
    place_name = "Ningun lugar"
    laptop = Laptop.find_by_id(attribs[:laptop_id])
    if laptop
      owner = laptop.owner
      place = owner.place
      owner_name = owner.getFullName
      place_name = place.getName
    end 
    str += "Esta maquina esta en manos de " + owner_name + " cuyo lugar de referencia es " + place_name

    cond = ["problem_type_id = ? and laptop_id = ?", attribs[:problem_type_id], attribs[:laptop_id]]
    reports = ProblemReport.find(:all, :conditions => cond)

    if reports != []
      str += " Este problema ya habia sido registrado #{reports.length} veces"
      
      non_solved_reports = []
      reports.each { |report|
        non_solved_reports.push(report.id) if !report.solved
      }
      if non_solved_reports != []
        str += ", de los cuales los siguientes no fueron solucionados: [" + non_solved_reports.join(',') + "]"
        str += " Es muy probable que este reporte sea repetido."
      end
    end

    @output["obj_data"] =  str
  end

  def save

    datos = JSON.parse(params[:payload])
    attribs = getData()

    if datos["id"]
      problem_report = ProblemReport.find_by_id(datos["id"])
      problem_report.update_attributes(attribs)
    else
      ProblemReport.create!(attribs)
    end

  end

  def getData
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:problem_type_id] = data_fields.pop.to_i
    attribs[:person_id] = current_user.person.id

    laptop_serial = data_fields.pop
    laptop = Laptop.find_by_serial_number(laptop_serial)
    attribs[:laptop_id] = laptop.id if laptop
    attribs[:solved] = data_fields.pop == 'N' ? false : true
    attribs[:comment] = data_fields.pop

    attribs
  end

  def delete
    ids = JSON.parse(params[:payload])
    ProblemReport.destroy(ids)
  end

end
