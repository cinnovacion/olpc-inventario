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
  def new
    version = prepare_form

    id = version ? version.model_id : -1
    models = buildSelectHash2(Model, id, "name", false, [])
    form_combobox(version, "model_id", _("Laptop model"), models)

    form_textfield(version, "name", _("Name"))
    form_textfield(version, "description", _("Description"))
    form_textfield(version, "vhash", _("Version hash"))
  end
end
