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
                                                                      
class DataImportController < ApplicationController
  around_filter :rpc_block

  def initialData

    definition = Hash.new

    models = Array.new
    models.push({:text => "Estudiantes", :value => "students", :selected => true})
    models.push({:text => "Profesoras", :value => "teachers", :selected => false})
    models.push({:text => "uuids", :value => "uuids", :selected => false})
    definition[:models] = models

    #For now we are going to use fixed format for every file type.
    formats = Array.new
    formats.push({:text => "Planilla", :value => "xls",:selected => true})
    definition[:formats] = formats

    @output["definition"] = definition

  end

  def import
    
    if params[:data]
      path = ReadFile.fromParam(params[:data])

      case params[:model]
        when "students"
          ReadFile.kidsFromFile(path,0)
        when "teachers"
          ReadFile.teachersFromFile(path,0)
        when "uuids"
          ReadFile.uuidFromFile(path," ")
      end

    else
      raise "Nada que importar."
    end
    @output["msg"] = "El archivo fue importado correctamente."
  end

end
