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
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
# 
#
# Author: Martin Abente - mabente@paraguayeduca.org
#

require 'fecha'

class BankDepositsController < SearchController
  attr_accessor :include_str

  def initialize
    super 
    @include_str = []
  end

  def search
    do_search(BankDeposit, { :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(BankDeposit)
    do_search(BankDeposit, { :include => @include_str })
  end

  def new

    bank_deposit = nil
    if params[:id]
      bank_deposit = BankDeposit.find(params[:id])
      @output["id"] = bank_deposit.id
    end
    
    @output["fields"] = []

    #id = bank_deposit ? bank_deposit.problem_solution_id : -1
    #options = buildSelectHash2(ProblemSolution, id, "getId", false, ["problem_solutions.id = ?", id])
    #h = { "label" => "Solucion", "datatype" => "select", :option => "problem_solutions", "text_value" => true }.merge( bank_deposit ? {"options" => options} : {} )
    #@output["fields"].push(h)

    h = { "label" => _("Deposit"), "datatype" => "textfield" }.merge( bank_deposit ? {"value" => bank_deposit.getDeposit } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Amount"), "datatype" => "numericfield" }.merge( bank_deposit ? {"value" => bank_deposit.getAmount } : {} )
    @output["fields"].push(h)

    fecha = Fecha.usDate(bank_deposit ? bank_deposit.getDepositedAt : Date.today.to_s)
    h = { "label" => _("Deposit date"), "datatype" => "date", :value => fecha  }
    @output["fields"].push(h)

    h = { "label" => _("Bank"), "datatype" => "textfield" }.merge( bank_deposit ? {"value" => bank_deposit.bank } : {} )
    @output["fields"].push(h)

  end

  def save

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    #attribs[:problem_solution_id] = data_fields.pop.to_i
    attribs[:deposit] = data_fields.pop
    attribs[:amount] = data_fields.pop.to_f
    attribs[:deposited_at] = data_fields.pop
    attribs[:bank] = data_fields.pop

    if datos["id"]
      bank_deposit = BankDeposit.find_by_id(datos["id"].to_i)
      bank_deposit.update_attributes(attribs)
    else
      BankDeposit.create!(attribs)
    end

    @output["msg"] = datos["id"] ? _("Changes saved.") : _("Deposit added.")  
  end

  def delete
    bank_deposits_ids = JSON.parse(params[:payload])
    BankDeposit.destroy(bank_deposits_ids)
    @output["msg"] = "Elements deleted."
  end

end
