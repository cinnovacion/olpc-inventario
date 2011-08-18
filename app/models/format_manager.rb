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
                   
require "iconv"                                                       
require "spreadsheet/excel"
include Spreadsheet

class FormatManager < ActiveRecord::Base


  ####
  #  generarExcel2(): 
  #  - genera una planilla de excel a partir de la matriz @datos
  #
  def self.generarExcel2(datos, titulos = [])

    # jugando con fuego.. puede haber carrera...
    file_name = RAILS_ROOT + "/tmp/" + Kernel.rand.to_s.split(".")[1] + ".xls"
    workbook = Excel.new(file_name)
    worksheet = workbook.add_worksheet

    # titulos 
    if titulos.length == 0
      filaTmp = datos.length > 0 ? datos[0] : []
      filaTmp.length.times { |i| titulos.push("Columna #{i+1}") }
    end
    worksheet.write(0, 0,titulos)

    # filas
    cnt = 1
    datos.each { |fila|
      self.clean_row(fila)
      worksheet.write(cnt, 0, fila)
      cnt += 1
    }
    workbook.close

    return file_name
  end

  ####
  # clean_row : changes boolean values (to @trueStr or @falseStr, accordingly)
  #
  # return true if row was cleaned, false otherwise. 
  def self.clean_row(row, trueStr="Si", falseStr="No")
    row_was_cleaned = false
  
    for i in 0 .. (row.length - 1)
      if row[i].is_a?(FalseClass) || row[i].is_a?(TrueClass) 
        row[i] = row[i] ? trueStr : falseStr 
        row_was_cleaned = true
      else
        row[i] = Iconv.conv('latin1', 'utf-8', row[i]) if row[i].is_a?(String)
      end
    end
    
    row_was_cleaned
  end

end
