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
                                                                        
class StatusesController < SearchController
  def new
    if params[:id]
      p = Status.find(params[:id])
      @output["id"] = p.id
    else
      p = nil
    end
    
    @output["fields"] = []

    h = { "label" => _("Description"),"datatype" => "textfield" }.merge( p ? {"value" => p.description } : {} )
    @output["fields"].push(h)

    h = { "label" => _("Abbreviation"),"datatype" => "textfield" }.merge( p ? {"value" => p.abbrev } : {} )
    @output["fields"].push(h)
  end

  def save
    datos = JSON.parse(params[:payload])
    attribs = Hash.new
    attribs[:description] = datos["fields"][0]
    attribs[:abbrev] = datos["fields"][1]
    
    Status.create!(attribs)
    
    @output["msg"] = datos["id"] ? _("Changes saved.") : _("New status added.")  
  end

  def delete
    ids = JSON.parse(params[:payload])
    Status.destroy(ids)
    @output["msg"] = _("Elements deleted.")
  end

end
