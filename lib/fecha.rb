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


module Fecha

  ###
  # fechaMenor == yyyy/mm/dd
  # fechaMayor == yyyy/mm/dd
  #
  def self.esMenorIgual(fechaMenor,fechaMayor)
    fechaMenorObj = self.getFechaObj(fechaMenor)
    fechaMayorObj = self.getFechaObj(fechaMayor)
    if fechaMenorObj <= fechaMayorObj
      ret = true
    else
      ret = false
    end
    ret
  end
  
  ###
  # fechaMenor == yyyy/mm/dd
  # fechaMayor == yyyy/mm/dd
  #
  def self.esMenor(fechaMenor,fechaMayor)
    fechaMenorObj = self.getFechaObj(fechaMenor)
    fechaMayorObj = self.getFechaObj(fechaMayor)
    if fechaMenorObj < fechaMayorObj
      ret = true
    else
      ret = false
    end
    ret
  end
  
  ####
  # recibe la fecha = yyyy/mm/dd 
  # retorna           = yyyy/mm/01  
  #
  def self.diaUnoMes(fecha)
     v = fecha.split(/-/)
     v[2] = "01"
     (v[0].to_s + "-" + v[1].to_s + "-" + v[2].to_s)
  end

  #
  def self.diaUnoMes(fecha)
     v = fecha.split(/-/)
     v[2] = "01"
     (v[0].to_s + "-" + v[1].to_s + "-" + v[2].to_s)
  end

  ###
  # fecha == yyyy/mm/dd
  #
  def self.getFechaObj(fecha)
    fechaTmp = fecha.split(/-/)
    Time.gm(fechaTmp[0],fechaTmp[1],fechaTmp[2])
  end

  def self.getFechaHora()
    Time.now
  end

  def self.getFecha(formato = "py")     
    timeObj = Time.now
    Fecha::getFechaFromTime(timeObj,formato)
  end
  
  def self.primerDiaDelMes(formato = "py")
    t = Time.now
    timeObj = Time.local(t.year,t.month,1)
    Fecha::getFechaFromTime(timeObj,formato)
  end

  def self.getFechaFromTime(timeObj,formato = "py")
    dia = Fecha::check_length(timeObj.day)
    mes = Fecha::check_length(timeObj.month)
    case formato
    when "py"
      [dia,mes,timeObj.year].join('-')
    when "us"
      [timeObj.year,mes,dia].join('-')
    end
  end

   def self.getHora(horaO = Time.now)
     hora = Fecha::check_length(horaO.hour)
     min = Fecha::check_length(horaO.min)
     seg = Fecha::check_length(horaO.sec)
     [hora,min,seg].join(':')
   end

   def self.usDate(fecha)
     v = fecha.split(/-/)
     v[1] = Fecha::check_length(v[1])
     v[0] = Fecha::check_length(v[0])
     (v[2].to_s + "-" + v[1].to_s + "-" + v[0].to_s)
   end

   def self.pyDate(fecha)
    fecha = fecha.to_s
	v = fecha.split(/-/)
	v[2] = Fecha::check_length(v[2])
     v[1] = Fecha::check_length(v[1])
     (v[2].to_s + "-" + v[1].to_s + "-" + v[0].to_s)
   end

   def self.check_length(s)
     s = s.to_s
     if s.length < 2
       s = "0" + s
     end
     s
   end

   def self.obtenerMes(mesNum)
     case mesNum.to_i
     when 1
       "Enero"
     when 2
       "Febrero"
     when 3
       "Marzo"
     when 4
       "Abril"
     when 5
       "Mayo"
     when 6
       "Junio"
     when 7
       "Julio"
     when 8
       "Agosto"
     when 9
       "Setiembre"
     when 10
       "Octubre"
     when 11
       "Noviembre"
     when 12
       "Diciembre"
     end
   end

end
