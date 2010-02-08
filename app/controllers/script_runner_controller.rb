class ScriptRunnerController < ApplicationController
  around_filter :rpc_block

  CODE = 0
  DESC = 1

  @@scripts = {
                "up_grade" => ["PlaceType.upGradeAll", "Realizar promocion de grados"] 
              }

  def script_list

    @output[:options] = @@scripts.keys.map { |key| { :text => @@scripts[key][DESC], :value => key } }
  end

  def run_script

    script_key = params[:script_key]
    script = @@scripts[script_key]

    msg = ""
    if !script

      msg = "No existe script #{script}"
    else

      eval(script[CODE])
      msg = "Todo en orden"
    end

    @output[:msg] = msg
  end

end
