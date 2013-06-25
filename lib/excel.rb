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

require 'iconv'

module Excel

  # - genera una planilla de excel a partir de la matriz @datos
  def self.generate(datos, titulos = [])
    workbook = Spreadsheet::Workbook.new
    worksheet = workbook.create_worksheet

    # titulos 
    if titulos.length == 0
      filaTmp = datos.length > 0 ? datos[0] : []
      filaTmp.length.times { |i| titulos.push("Columna #{i+1}") }
    end
    worksheet.row(0).replace(titulos)

    # filas
    cnt = 1
    datos.each { |fila|
      clean_row(fila)
      worksheet.row(cnt).replace(fila)
      cnt += 1
    }

    file_name = Rails.root.join("/tmp/", Kernel.rand.to_s.split(".")[1] + ".xls").to_s
    workbook.write file_name
    return file_name
  end

  # clean_row : changes boolean values (to @trueStr or @falseStr, accordingly)
  def self.clean_row(row, trueStr="Si", falseStr="No")
    for i in 0 .. (row.length - 1)
      if row[i].is_a?(FalseClass) || row[i].is_a?(TrueClass) 
        row[i] = row[i] ? trueStr : falseStr 
      else
        row[i] = Iconv.conv('latin1', 'utf-8', row[i]) if row[i].is_a?(String)
      end
    end
  end
end
