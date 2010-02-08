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
# TODO:
# - hay sentencias de proteccion (!= "null") pq en Qooxdoo 0.6.1 el null venia como string. En el 0.7.1 ya no ocurre
#
#

# # #
# Author: Raúl Gutiérrez
# E-mail Address: rgs@paraguayeduca.org
# 2009
# # #



class SearchController < ApplicationController
  around_filter :rpc_block
  before_filter :set_vista
  attr_accessor :vista
  
  def set_vista
    # soporte p/ vistas
    if params[:vista] and params[:vista] != "null"
      @vista = params[:vista]
    else
      @vista = ""
    end
  end
  
  def do_search(class_ref,options)

    payload = params[:payload] ? JSON.parse(params[:payload]) : {}

    ban = false
    condicion = ""

    options = options ? options : { }

    ban = true if payload
    condicion = convertir(payload)
    #raise condicion.to_json
 
    # Aca habria que ver si la vista (ademas de tener columnas distintas) tiene condicions especiales via if  @vista == ""
    # esta parte es para unir la condicion que vino desde arriba y la que vino del lado cliente
    # condicion solamente es el que vino del cliente y options[:conditions] lo que se vino del controller que llamo
    if options[:conditions]
      if ban
        condicion = merge_conditions(options[:conditions],condicion)
      else
        condicion = options[:conditions]
      end
    end
    #ahora condicion se tiene que mezclar con lo que viene de la base de datos
    ret_columnas = @vista == "" ? class_ref.getColumnas() : class_ref.getColumnas(@vista)

    case ret_columnas.class.to_s
    when "Array"
      columnas = ret_columnas
    when "Hash"
      columnas = ret_columnas[:columnas]
            #raise ret_columnas[:conditions].to_json
      if ret_columnas[:conditions]
        if condicion == ""
          condicion = ret_columnas[:conditions]
        else
          condicion = merge_conditions(ret_columnas[:conditions],condicion)
        end
        ban = true
      end
      # Sobre escribo el metodo de ordenamiento si me envian uno desde el modelo
      if ret_columnas[:order]
        options[:order] = ret_columnas[:order]
      end

      # Verifico si hay pedido de Join
      options[:joins] = ret_columnas[:joins] if ret_columnas[:joins]

      # Verifico si hay include
      if ret_columnas[:include]
        if !options[:include]
          options[:include] = ret_columnas[:include]
        else
          options[:include] += ret_columnas[:include]
        end
      end
      
      # Verifico si pide un group by 
      options[:group] = ret_columnas[:group] if ret_columnas[:group]

      # Verfico si hay vector de visibilidad
      @output[:columnas_visibles] = ret_columnas[:columnas_visibles] if ret_columnas[:columnas_visibles]
    end
    #carga los titulos de las columnas 
    @output["cols_titles"] = columnas.map{|x| x[:name]}
    options.merge!( {:conditions => condicion } ) if ban
    
    # Cantidad de registros por pagina
    per_page =  params[:cant_fila] ? params[:cant_fila].to_i : 30
    options[:per_page] = per_page
    #options[:order] = opt if not options[:order] and opt != ""
    
    # options[:class_name] = class_ref.class_name
    page_num = params[:page] || 1
    options[:page] = page_num

    #RAILS_DEFAULT_LOGGER.error("\n\n\n\n #{options.to_json} \n\n\n\n\n\n ")
    objetos = class_ref.paginate(options)
   
    
    ret = getDataToSend(class_ref,objetos)
    @output["rows"] = ret

    # WillPaginate::Collection
    @output["results"] = objetos.total_entries
    @output["page_count"] = objetos.total_pages

    
    # Soporte p/ el boton "Elegir" en Abm2
    if defined? class_ref.getChooseButtonColumns != nil
      h = @vista == "" ? class_ref.getChooseButtonColumns : class_ref.getChooseButtonColumns(@vista)
      if h["desc_col"].class.to_s == "Fixnum"
        h["desc_col"] = {:columnas => [h["desc_col"]],:separator => ""}
      end
      @output["elegir_data"] = h
    end

    # fecha actual
    @output["fecha"] = Fecha::getFecha()

  end
  
  
  def crearColumnasCriterios(class_ref)
    ret = []
    ret_columnas = @vista == "" ? class_ref.getColumnas() : class_ref.getColumnas(@vista)

    case ret_columnas.class.to_s

     when "Array"
       columnas = ret_columnas
     when "Hash"
       columnas = ret_columnas[:columnas]
    end

    columnas.each{ |x|

      sel = x[:selected] && x[:selected] == true ? true : false
      tmp = {:text=>x[:name],:value=>x[:key],:selected => sel}
      tmp.merge!({:datatype => x[:datatype]}) if x[:datatype]
      tmp.merge!({:options => x[:options]}) if x[:options]
      tmp.merge!({:data => eval(x[:data])}) if x[:data]
      tmp.merge!({:vista => x[:vista]}) if x[:vista]
      tmp.merge!({:width => x[:width]}) if x[:width]
      ret.push(tmp)
    }

    @output["criterios"] = ret
  end
  
  private

  ##
  # Retorna una matriz de datos que se va cargar en la tabla del cliente
  #  como efecto secundarios se pobla @output["ids_para_abm"] con los IDs de los objetos que estamos enviando
  #
  def getDataToSend(class_ref,objetos)
    ret = []
    ret_columnas = @vista == "" ? class_ref.getColumnas() : class_ref.getColumnas(@vista)
    case ret_columnas.class.to_s
    when "Array"
      columnas = ret_columnas
    when "Hash"
      columnas = ret_columnas[:columnas]
    end

    objetos.each{ |x|
      
      tmp = Array.new
      for c in columnas
        if c[:related_attribute]
          # Agregue esta rama para el caso de que te interesen columnas de objetos relacionados (via belongs_to generalmente)
          begin
            newCol = eval("x." + c[:related_attribute])
            newCol =  "" if newCol == nil
          rescue
            newCol =  ""  # no tiene el objeto relacionado (probablemente y ojala, pq osino estamos escondiendo otro error)
          end
        else
          # Codigo original de Uchi.
          newCol = x[c[:key]]? x[c[:key]] : ""
        end
        tmp.push(newCol)
      end
      ret.push(tmp)

    }
    ret
  end
  
  def merge_conditions(a,b)

   
    conditions = [a,b]
    conditions.delete([""])

    ret = [conditions.map { |condition| condition[0] }.join(" and ")]
    ret += a[1,a.length] if a.length > 1
    ret += b[1,b.length] if b.length > 1
    ret
  end

  def convertir(components)

    cond = [""]
    condStrArr = []
    components.keys.each { |key| 

      oprLen = components[key]["operators"].length
      valLen = components[key]["values"].length
    
      components[key]["values"].map { |m| 
        begin
            m.gsub!(/n|ñ/,'(n|ñ)')
            m.gsub!(/a|á/,'(a|á)')
            m.gsub!(/e|é/,'(e|é)')
            m.gsub!(/i|í/,'(i|í)')
            m.gsub!(/o|ó/,'(o|ó)')
            m.gsub!(/u|ú/,'(u|ú)')
        rescue
        end;
      }
    
      oprArr = []
      (valLen/oprLen).times do

        subOprStr = components[key]["operators"].map { |opr|
            " #{key} #{opr} "
        }.join(" and ")
        oprArr.push("(#{subOprStr})")
      end
      oprStr = oprArr.join(" or ")
      condStrArr.push("(#{oprStr})")
      cond += components[key]["values"]

    }

    cond[0] = condStrArr.join(" and ")
    cond
  end

end
