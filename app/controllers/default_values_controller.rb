#########
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
# Author: Martin Abente - mabente@paraguayeduca.org



class DefaultValuesController < SearchController
  attr_accessor :include_str

  def initialize
    super 
    @include_str = []
  end

  def search
    do_search(DefaultValue, { :include => @include_str })
  end

  def search_options
    crearColumnasCriterios(DefaultValue)
    do_search(DefaultValue, { :include => @include_str })
  end

  def new

    value = nil
    if params[:id]
      value = DefaultValue.find_by_id(params[:id])
      @output["id"] = value.id
    end
    
    @output["fields"] = []

    h = { "label" => _("Key"),"datatype" => "textfield" }.merge( value ? {"value" => value.getKey } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Value"),"datatype" => "textfield" }.merge( value ? {"value" => value.getValue } : {} )
    @output["fields"].push(h)

  end

  def save

    datos = JSON.parse(params[:payload])
    data_fields = datos["fields"].reverse

    attribs = Hash.new
    attribs[:key] = data_fields.pop
    attribs[:value] = data_fields.pop

    if datos["id"]
 
      value = DefaultValue.find_by_id(datos["id"].to_i)
      value.update_attributes(attribs)
    else
   
      DefaultValue.create!(attribs)
    end

  end

  def delete
    to_delete_ids = JSON.parse(params[:payload])
    DefaultValue.destroy(to_delete_ids)
    @output["msg"] = _("Elements deleted.")
  end

  def requestKeys

    keys = JSON.parse(params[:data])

    values = DefaultValue.find(:all, :conditions => ["default_values.key in (?)", keys])

    hash = Hash.new
    values.each { |value|
      hash[value.key] = value.value
    }

    @output[:values] = hash
  end

end
