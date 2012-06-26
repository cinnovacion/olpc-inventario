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

require 'fecha'

class ProblemSolutionsController < SearchController
  attr_accessor :include_str

  def initialize
    super
    @include_str = [:solution_type, :solved_by_person]
  end

  def search
    do_search(ProblemSolution,{:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(ProblemSolution)
    do_search(ProblemSolution,{:include => @include_str })
  end

  def simple_solution
    @output["window_title"] = _("Soluciones Simples")
    @output["with_tabs"] = true
    @output["fields"] = Array.new

    h = { "label" => _("\#Report*"), "datatype" => "select", "options" => [], "option" => "problem_reports", "text_value" => true }
    @output["fields"].push(h)

    solution_types = buildSelectHash2(SolutionType, -1, "getName", false)
    h = { "label" => _("Solution*"), "datatype" => "combobox", "options" => solution_types }
    @output["fields"].push(h)

    fecha = Fecha.usDate(Date.today.to_s)
    h = { "label" => _("Date solved"), "datatype" => "date", :value => fecha  }
    @output["fields"].push(h)

    h = { "label" => _("Comments"), "datatype" => "textarea","width" => 250, "height" => 50}
    @output["fields"].push(h)

    h = { "datatype" => "tab_break", "title" => _("Deposits") }
    @output["fields"].push(h)

    # Table for solutions deposits, aka Ca$h.
    @output["fields"].push(deposits_view)
  end

  ###
  # FIXME: an explanation on what 'impure_attribs' are might be useful.
  #
  def save_simple_solution
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    impure_attribs = Hash.new
    impure_attribs[:problem_report_id] = data_fields.pop.to_i
    impure_attribs[:solution_type_id] = data_fields.pop.to_i
    impure_attribs[:solved_by_person_id] = current_user.person.id
    impure_attribs[:created_at] = data_fields.pop
    impure_attribs[:comment] = data_fields.pop
    bank_deposits_data = parse_deposits(data_fields.pop)

    raise _("Editing not allowed in this window.") if datos["id"]
    ProblemSolution.register_simple_solution(impure_attribs, bank_deposits_data)

    @output["msg"] =  _("Solution saved.")  

    true
  end

  def delete
    ids = JSON.parse(params[:payload])
    ProblemSolution.destroy(ids)
    @output["msg"] = "Elements deleted."
  end

  def change_solution
    @output["with_tabs"] = true
    @output["window_title"] = _("Laptop exchange")
    @output["verify_before_save"] = true
    @output["verify_save_url"] = "/problem_solutions/verify_change_solution"

    @output["fields"] = []

    h = { "label" => _("Report"), "datatype" => "select", "options" => [], "option" => "problem_reports", "text_value" => true }
    @output["fields"].push(h)

    h = { "label" => _("Serial \# of replacement laptop"), "datatype" => "textfield" }
    @output["fields"].push(h)

    h = { "label" => _("Comments"), "datatype" => "textarea","width" => 250, "height" => 50 }
    @output["fields"].push(h)

    h = { "datatype" => "tab_break", "title" => _("Deposits") }
    @output["fields"].push(h)

    # Table for solutions deposits, aka Ca$h.
    @output["fields"].push(deposits_view)

    true
  end

  def verify_change_solution
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"]

    problem_report_id = data_fields[0]
    replacement_laptop_srl = data_fields[1]

    problem_report = ProblemReport.find_by_id(problem_report_id)
    owner_laptop = problem_report.laptop
    replacement_laptop = Laptop.find_by_serial_number(replacement_laptop_srl)

    if !problem_report || !owner_laptop || !replacement_laptop
      raise _("The operation can't be completed, the provided data doesn't exist in the system.") 
    end

    str_vars = [owner_laptop.getSerialNumber, replacement_laptop_srl]
    msg = "Are you sure you want to replace the laptop %s with %s, " % str_vars
    str_vars = [problem_report_id, problem_report.problem_type.getName]
    msg += "as a solution for problem number %s (%s)?" % str_vars

    @output["obj_data"] =  msg
  end

  def save_change_solution
    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = {}
    attribs[:problem_report_id] = data_fields.pop.to_i
    rep_dev_srl = data_fields.pop
    attribs[:comment] = data_fields.pop
    bank_deposits_data = parse_deposits(data_fields.pop)
    attribs[:solved_by_person_id] = current_user.person.id

    raise _("Editing not allowed in this window.") if datos["id"]
    ProblemSolution.register_change(attribs, rep_dev_srl, bank_deposits_data)

    @output["msg"] = _("Solution saved.")
    true
  end

  def new
    raise _("Not available")
  end

  def save
    raise _("Not available")
  end

  private

  def parse_deposits(data_field)
    deposits_list = []

    data_field.each { |data| 

      raise _("Invalid deposit number.") if !data["Deposito"].match("^\\d+$")
      raise _("Invalid specified amount.") if !data["Monto"].match("^\\d+(.\\d+|)$")
      raise _("Invalid date.") if !data["Fecha"].match("^(\\d+)-(\\d+)-(\\d+)$")

      deposits_list.push([data["Deposito"], data["Monto"].to_f, data["Fecha"]]) 
    }

    deposits_list
  end

  ####
  # FIXME: labels can't be translated here cause it will break code that depends on the value 
  #        of the labels. Can't we use something like UserData or tags to not depend on the labels?
  #
  #
  def deposits_view(problem_solution = nil)

    options = Array.new
    h = { "label" => "Deposito", "datatype" => "textfield" }
    options.push(h)

    h = { "label" => "Monto", "datatype" => "textfield" }
    options.push(h)

    h = { "label" => "Fecha", "datatype" => "date" }
    options.push(h)

    bank_deposits = Array.new
    bank_deposits = problem_solution.bank_deposits.map { |bank_deposit| 
     [
       { :value => bank_deposit.deposit, :text => bank_deposit.deposit},
       { :value => bank_deposit.amount, :text => bank_deposit.amount},
       { :value => Fecha.usDate(bank_deposit.getDepositedAt), :text => Fecha.usDate(bank_deposit.getDepositedAt)}
     ] 
    } if problem_solution

    h = {"label" => "", "datatype" => "dyntable", :widths => [120, 80, 120], "options" => options, "data" => bank_deposits }
    h
  end

end
