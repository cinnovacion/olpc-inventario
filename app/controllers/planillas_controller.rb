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
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #
                                                                
class PlanillasController < ApplicationController
  around_filter :rpc_block, :only => [:planilla_carga_datos]


  ###
  # HACK:
  #  - Usamos iFrames para el tema de impresion (por limitaciones del navegador, tendiramos que usar 
  #    Adobe Air)
  #  - Entonces como no podemos hacer POST con un iFrame y necesitamos enviar muchos datos hacemos doble
  #    llamada:
  #        * la 1era con POST para pasar los datos de la planilla que quedan retenido via session
  #        * la 2da via GET para retirar la planilla..
  #
  def planilla_carga_datos
    session[:datos] = JSON.parse(params[:datos])
    session[:titulos] = params[:titulos] ? JSON.parse(params[:titulos]) : []
  end

  def planilla
    file_name = FormatManager.generarExcel2(session[:datos],session[:titulos])
    send_file(file_name,:filename => "datos.xls",:type => "application/vnd.ms-excel",:stream => false )
  end

end
