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
                                                                      
class ProblemSolutionsController < SearchController
  attr_accessor :include_str

  def initialize
    super
    @include_str = [{:solution_type => :part_type}, :solved_by_person, {:src_part => [:laptop, :battery, :charger]}, {:dst_part => [:laptop, :battery, :charger]}]
  end

  def search
    do_search(ProblemSolution,{:include => @include_str })
  end

  def search_options
    crearColumnasCriterios(ProblemSolution)
    do_search(ProblemSolution,{:include => @include_str })
  end

  def simple_solution

    @output["window_title"] = "Soluciones Simples"
    @output["fields"] = Array.new

    h = { "label" => "#Reporte*", "datatype" => "select", "options" => [], "option" => "problem_reports", "text_value" => true }
    @output["fields"].push(h)

    inc = [:part_type]
    cond = ["solution_types.part_type_id is NULL or part_types.internal_tag not in (?)", ["battery", "charger", "laptop"] ]
    solution_types = buildSelectHash2(SolutionType, -1, "getName", false, cond, [], inc)
    h = { "label" => "Solucion*", "datatype" => "combobox", "options" => solution_types }
    @output["fields"].push(h)

    h = { "label" => "Serial Laptop Respuesto", "datatype" => "select", "options" => [], :option => "laptops", "text_value" => true }
    @output["fields"].push(h)

    fecha = Fecha.usDate(Date.today.to_s)
    h = { "label" => "Fch. Solucion", "datatype" => "date", :value => fecha  }
    @output["fields"].push(h)

    h = { "label" => "Comentarios", "datatype" => "textarea","width" => 250, "height" => 50}
    @output["fields"].push(h)

    h = { "datatype" => "tab_break", "title" => "Depositos" }
    @output["fields"].push(h)

    # Table for solutions deposits, aka Ca$h.
    @output["fields"].push(deposits_view)

  end

  def save_simple_solution

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    impure_attribs = Hash.new
    impure_attribs[:problem_report_id] = data_fields.pop.to_i
    impure_attribs[:solution_type_id] = data_fields.pop.to_i
    impure_attribs[:solved_by_person_id] = current_user.person.id
    impure_attribs[:replacement_laptop_serial] = data_fields.pop
    impure_attribs[:created_at] = data_fields.pop
    impure_attribs[:comment] = data_fields.pop
    bank_deposits_data = parse_deposits(data_fields.pop)

    raise "No esta permitido editar desde esta ventana." if datos["id"]
    ProblemSolution.register_simple_solution(impure_attribs, bank_deposits_data)

    true
  end

  def delete
    ids = JSON.parse(params[:payload])
    ProblemSolution.destroy(ids)
  end

  def quick_solution

    @output["window_title"] = "Reparacion Rapida"
    @output["fields"] = []

    problem_types = buildSelectHash2(ProblemType, -1, "getName", false)
    h = { "label" => "Problema*", "datatype" => "combobox", "options" => problem_types }
    @output["fields"].push(h)

    h = { "label" => "#Serial Laptop Reportada*", "datatype" => "select", "options" => [], :option => "laptops", "text_value" => true }
    @output["fields"].push(h)

    inc = [:part_type]
    cond = ["solution_types.part_type_id is NULL or part_types.internal_tag not in (?)", ["battery", "charger", "laptop"] ]
    solution_types = buildSelectHash2(SolutionType, -1, "getName", false, cond, [], inc)
    h = { "label" => "Solucion*", "datatype" => "combobox", "options" => solution_types }
    @output["fields"].push(h)

    h = { "label" => "#Serial Laptop Repuesto*", "datatype" => "select", "options" => [], :option => "laptops", "text_value" => true }
    @output["fields"].push(h)

    h = { "label" => "Comentarios", "datatype" => "textarea","width" => 250, "height" => 50 }
    @output["fields"].push(h)

    h = { "datatype" => "tab_break", "title" => "Depositos" }
    @output["fields"].push(h)

    # Table for solutions deposits, aka Ca$h.
    @output["fields"].push(deposits_view)

    true
  end

  def save_quick_solution

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    problem_type_id = data_fields.pop.to_i
    laptop_srl = data_fields.pop.to_s
    solution_type_id = data_fields.pop.to_i
    replacement_laptop_srl = data_fields.pop.to_s
    comment = data_fields.pop.to_s
    bank_deposits_data = parse_deposits(data_fields.pop)

    raise "No esta permitido editar desde esta ventana." if datos["id"]
    ProblemSolution.register_quick_solution(problem_type_id, laptop_srl, solution_type_id, replacement_laptop_srl, current_user.person, comment, bank_deposits_data)

    true
  end

  def change_solution

    @output["window_title"] = "Cambio de (Laptop | Bateria | Cargador)"
    @output["verify_before_save"] = true
    @output["verify_save_url"] = "/problem_solutions/verify_change_solution"

    @output["fields"] = []

    part_types = buildSelectHash2(PartType,-1,"getDescription",false,["part_types.internal_tag in (?)", ["laptop", "battery", "charger"]])
    h = { "label" => "Dispositivo","datatype" => "combobox","options" => part_types }
    @output["fields"].push(h)

    h = { "label" => "Reporte", "datatype" => "select", "options" => [], "option" => "problem_reports", "text_value" => true }
    @output["fields"].push(h)

    h = { "label" => "#Serial del Original", "datatype" => "textfield" }
    @output["fields"].push(h)

    h = { "label" => "#Serial del Repuesto", "datatype" => "textfield" }
    @output["fields"].push(h)

    h = { "label" => "Comentarios", "datatype" => "textarea","width" => 250, "height" => 50 }
    @output["fields"].push(h)

    h = { "datatype" => "tab_break", "title" => "Depositos" }
    @output["fields"].push(h)

    # Table for solutions deposits, aka Ca$h.
    @output["fields"].push(deposits_view)

    true
  end

  def verify_change_solution

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    part_type_id = data_fields.pop.to_i
    problem_report_id = data_fields.pop.to_i
    orig_dev_srl = data_fields.pop
    rep_dev_srl = data_fields.pop

    part_type = PartType.find_by_id(part_type_id)
    problem_report = ProblemReport.find_by_id(problem_report_id)

    dev_tag = part_type.internal_tag
    classname = dev_tag.camelize.constantize

    orig_dev = classname.find_by_serial_number(orig_dev_srl)
    rep_dev = classname.find_by_serial_number(rep_dev_srl)


    msg = "Esta seguro que desea cambiar el dispositivo #{part_type.getDescription}? "
    msg += "Como solucion al problema numero #{problem_report_id} (#{problem_report.problem_type.getName}). "
    if !orig_dev || !rep_dev
      msg += "Teniendo en cuenta que los siguientes seriales, "
      msg += "#{orig_dev_srl}, " if !orig_dev
      msg += "#{rep_dev_srl}, " if !rep_dev 
      msg += "no se encuentran registrados en el sistema."
    end

  @output["obj_data"] =  msg
  end

  def save_change_solution

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    part_type_id = data_fields.pop.to_i
    problem_report_id = data_fields.pop.to_i
    orig_dev_srl = data_fields.pop
    rep_dev_srl = data_fields.pop
    comment = data_fields.pop.to_s
    bank_deposits_data = parse_deposits(data_fields.pop)

    raise "No esta permitido editar desde esta ventana." if datos["id"]
    ProblemSolution.register_change(part_type_id, problem_report_id, orig_dev_srl, rep_dev_srl, current_user.person, comment, bank_deposits_data)

    true
  end

  def new

    raise "Debe seleccionar una solucion" if !params[:id]
    problem_solution = ProblemSolution.find_by_id(params[:id].to_i)

    @output["id"] = problem_solution.id
    @output["window_title"] = "Edicion de comentario y fecha"
    @output["fields"] = Array.new

    fecha = Fecha.usDate(problem_solution.getDate)
    h = { "label" => "Fch. Solucion", "datatype" => "date", :value => fecha  }
    @output["fields"].push(h)

    comment = problem_solution.getComment
    h = { "label" => "Comentarios", "datatype" => "textarea","width" => 250, "height" => 50, :value => comment }
    @output["fields"].push(h)

    #h = { "datatype" => "tab_break", "title" => "Depositos" }
    #@output["fields"].push(h)

    #@output["fields"].push(deposits_view(problem_solution))
  end

  def save

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:created_at] = data_fields.pop
    attribs[:comment] = data_fields.pop
    #bank_deposits_data = parse_deposits(data_fields.pop)

    problem_solution = ProblemSolution.find_by_id(datos["id"].to_i)
    raise "La solucion a editar no existe." if !problem_solution
    
    problem_solution.update_attributes(attribs)
    #BankDeposit.register(problem_solution.id, bank_deposits_data)
  end

  private

  def parse_deposits(data_field)
    deposits_list = []

    data_field.each { |data| 

      raise "El deposito no es valido" if !data["Deposito"].match("^\\d+$")
      raise "El monto no es valido." if !data["Monto"].match("^\\d+(.\\d+|)$")
      raise "La fecha no es valida." if !data["Fecha"].match("^(\\d+)-(\\d+)-(\\d+)$")

      deposits_list.push([data["Deposito"], data["Monto"].to_f, data["Fecha"]]) 
    }

    deposits_list
  end

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
