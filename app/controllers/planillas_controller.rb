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
# Author: Raúl Gutiérrez <rgs@paraguayeduca.org>

require 'excel'

class PlanillasController < ApplicationController
  around_filter :rpc_block, :only => [:planilla_carga_datos]

  ###
  # HACK:
  #  - We use iFrames because its the only way of bringing files in an AJAX fashion (true?) 
  #  - So, we can't do POST with an iFrame and lots of data needs to be send, so double-call:
  #        * 1st: a POST to pass the data about the spreadsheet we want to generate (it gets saved in the session)
  #        * 2nd: we do GET request to pick up our spreadsheet.
  #
  def planilla_carga_datos
    session[:datos] = JSON.parse(params[:datos])
    session[:titulos] = params[:titulos] ? JSON.parse(params[:titulos]) : []
  end

  def planilla
    file_name = Excel.generate(session[:datos],session[:titulos])
    send_file(file_name,:filename => "datos.xls",:type => "application/vnd.ms-excel",:stream => false )
  end
end
