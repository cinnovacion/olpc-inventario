#     Copyright Daniel Drake 2012
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

class SoftwareVersionsController < SearchController

  def search
    do_search(SoftwareVersion, nil)
  end

  def search_options
    crearColumnasCriterios(SoftwareVersion)
    do_search(SoftwareVersion, nil)
  end

  def new
    if params[:id]
      version = SoftwareVersion.find(params[:id])
      @output["id"] = version.id
    else
      version = nil
    end

    @output["fields"] = []

    id = version ? version.model_id : -1
    models = buildSelectHash2(Model, id, "name", false, [])
    h = { "label" => _("Laptop model"), "datatype" => "combobox", "options" => models }
    @output["fields"].push(h)

    h = { "label" => _("Name"), "datatype" => "textfield" }.merge(version ? {"value" => version.name} : {})
    @output["fields"].push(h)

    h = { "label" => _("Description"), "datatype" => "textfield" }.merge(version ? {"value" => version.description} : {})
    @output["fields"].push(h)

    h = { "label" => _("Version hash"), "datatype" => "textfield" }.merge(version ? {"value" => version.vhash} : {})
    @output["fields"].push(h)
  end

  def save
    data = JSON.parse(params[:payload])
    fields = data["fields"].reverse

    attribs = Hash.new
    attribs[:model_id] = fields.pop
    attribs[:name] = fields.pop
    attribs[:description] = fields.pop
    attribs[:vhash] = fields.pop

    if data["id"]
      version = SoftwareVersion.find(data["id"]).update_attributes!(attribs)
    else
      SoftwareVersion.create!(attribs)
    end

    @output["msg"] = data["id"] ? _("Changes saved.") : _("Information added.")
  end

  def delete
    ids = JSON.parse(params[:payload])
    SoftwareVersion.destroy(ids)
    @output["msg"] = "Elements deleted."
  end
end
