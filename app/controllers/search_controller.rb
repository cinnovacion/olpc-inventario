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
# - set_vista (in spanish view) should be rename to something like set_models_scope
#   since that is what it really does. On the client side the same should be done. 
# - cleanup?
# - is checking strings against "null" still needed? This was an old (0.6.1) Qooxdoo
#   bug. 
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

  #####
  # check if you would like to scope your models?
  #
  def set_vista
    if params[:vista] and params[:vista] != "null"
      @vista = params[:vista]
    else
      @vista = ""
    end
  end
  
  ####
  # this method does the actual search of a Model's objects. 
  #
  def do_search(clazz_ref,options)
    @find_options = options ? options : {}
    extract_client_options()
    clients_conditions = extract_conditions()

    # merge the search conditions that come from the client request with those set
    # in the controller where do_search() was called. 
    @search_conditions = merge_conditions(@find_options[:conditions], clients_conditions)

    # We need to ask the model what columns and what other conditions does it want. 
    @model_config = @vista == "" ? clazz_ref.getColumnas() : clazz_ref.getColumnas(@vista)

    case @model_config.class.to_s
    when "Array"
      @output["cols_titles"] = @model_config.map { |x| x[:name] }
    when "Hash"
      extract_model_config()
    end

    @find_options.merge!( { :conditions => @search_conditions } ) if @search_conditions[0] != ""

    returned_objects = clazz_ref.paginate(@find_options)

    @output["rows"] = getDataToSend(clazz_ref, returned_objects)
    @output["results"] = returned_objects.total_entries
    @output["page_count"] = returned_objects.total_pages
    @output["fecha"] = Fecha::getFecha()
    setup_choose_button_options(clazz_ref)
  end
  
  private

  ####
  # Extract options sent by our HTTP client. 
  #
  def extract_client_options()
    @client_payload = params[:payload] ? JSON.parse(params[:payload]) : {}

    # Some options for the listing of rows.  
    @find_options[:per_page] = params[:cant_fila] ? params[:cant_fila].to_i : 30
    @find_options[:page] = params[:page] || 1
  end


  ####
  # setup options established in the Model. 
  #
  def extract_model_config()
    @output["cols_titles"] = @model_config[:columnas].map { |x| x[:name] }

    @search_conditions = merge_conditions(@model_config[:conditions], @search_conditions)

    # if the order was established in the Model, we use that one. 
    @find_options[:order] = @model_config[:order] if @model_config[:order]

    # Any joins configured in the model?
    @find_options[:joins] = @model_config[:joins] if @model_config[:joins]

    # include?
    if @model_config[:include]
      if !@find_options[:include]
        @find_options[:include] = @model_config[:include]
      else
        @find_options[:include] += @model_config[:include]
      end
    end
    
    # group by?
    @find_options[:group] = @model_config[:group] if @model_config[:group]

    # in the Model you can set what columns should be displayed in the client-side listing. 
    @output["columnas_visibles"] = @model_config[:columnas_visibles] if @model_config[:columnas_visibles]
  end


  ####
  # Create the data needed for the combobox the lets the user search by 
  # different criteria in our Listings. 
  #
  def crearColumnasCriterios(clazz_ref)
    model_config = @vista == "" ? clazz_ref.getColumnas() : clazz_ref.getColumnas(@vista)
    column_config = model_config.is_a?(Array) ? model_config : model_config[:columnas]

    @output["criterios"] = column_config.map { |x|
      sel = x[:selected] && x[:selected] == true ? true : false
      tmp = { :text=> x[:name], :value => x[:key], :selected => sel}
      tmp.merge!({:datatype => x[:datatype]}) if x[:datatype]
      tmp.merge!({:options => x[:options]}) if x[:options]
      tmp.merge!({:data => eval(x[:data])}) if x[:data]
      tmp.merge!({:vista => x[:vista]}) if x[:vista]
      tmp.merge!({:width => x[:width]}) if x[:width]
      tmp
    }
  end


  ####
  # Config option for the 'Choose' button. 
  #
  def setup_choose_button_options(clazz_ref)
    if clazz_ref.respond_to?(:getChooseButtonColumns)
      h = @vista == "" ? clazz_ref.getChooseButtonColumns : clazz_ref.getChooseButtonColumns(@vista)
      if h["desc_col"].class.to_s == "Fixnum"
        h["desc_col"] = {:columnas => [h["desc_col"]],:separator => ""}
      end
      @output["elegir_data"] = h
    end
  end


  ##
  # We return the table (array of arrays) of data that will be loaded in the Listing 
  # on the Client side. 
  #
  def getDataToSend(clazz_ref, objects)
    column_config = @model_config.is_a?(Array) ? @model_config : @model_config[:columnas]

    objects.map { |obj|
      column_config.map { |c| 
        if c[:related_attribute]
          begin
            #It would be nice to use obj.send(...) But in getColumnas some strings 
            #include "()" which breaks the send call.
            newCol = eval("obj." + c[:related_attribute])
            newCol =  "" if newCol == nil
          rescue
            newCol =  ""
          end
        else
          newCol = obj[c[:key]] ? obj[c[:key]] : ""
        end
        newCol
      }
    }
  end

  ###
  # merges 2 conditions arrays in ActiveRecord's format
  #
  def merge_conditions(a,b)
    a = a == nil ? [""] : a
    b = b == nil ? [""] : b

    conditions = [a,b]
    conditions.delete([""])

    ret = [conditions.map { |condition| condition[0] }.join(" and ")]
    ret += a[1,a.length] if a.length > 1
    ret += b[1,b.length] if b.length > 1
    ret
  end

  ####
  # extract the conditions sent by the client request and 
  # return them in ActiveRecords conditions format
  def extract_conditions()
    cond = [""]
    condStrArr = []

    @client_payload.keys.each { |key| 
      oprLen = @client_payload[key]["operators"].length
      valLen = @client_payload[key]["values"].length
    
      # we treat letter with/without accents indistinctively. 
      @client_payload[key]["values"].map { |m| 
        begin
            m.gsub!(/n|ñ/,'(n|ñ)')
            m.gsub!(/a|á/,'(a|á)')
            m.gsub!(/e|é/,'(e|é)')
            m.gsub!(/i|í/,'(i|í)')
            m.gsub!(/o|ó/,'(o|ó)')
            m.gsub!(/u|ú/,'(u|ú)')
        rescue
        end
      }
    
      oprArr = []
      (valLen / oprLen).times do
        subOprStr = @client_payload[key]["operators"].map { |opr|
          " #{key} #{opr} "
        }.join(" and ")
        oprArr.push("(#{subOprStr})")
      end
      oprStr = oprArr.join(" or ")
      condStrArr.push("(#{oprStr})")
      cond += @client_payload[key]["values"]
    }

    cond[0] = condStrArr.join(" and ")
    cond
  end

end
