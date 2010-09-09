#     Copyright Paraguay Educa 2009, 2010
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

class ScriptRunnerController < ApplicationController
  around_filter :rpc_block

  CLASS = 0
  METHOD = 1
  DESC = 2

  @@scripts = {
                "up_grade" => [PlaceType, "upGradeAll", "Realizar promocion de grados"] 
              }

  def script_list

    @output[:options] = @@scripts.keys.map { |key| { :text => @@scripts[key][DESC], :value => key } }
  end

  def run_script

    script_key = params[:script_key]
    script = @@scripts[script_key]

    msg = ""
    if !script
      msg = _("No such script %s") % script
    else
      script[CLASS].send(script[METHOD])
      msg = _("Script run successfully. ")
    end

    @output[:msg] = msg
  end

end
