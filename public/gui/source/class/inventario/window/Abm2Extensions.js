
//     Copyright Paraguay Educa 2009
//
//     This program is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.
//
//     This program is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU General Public License for more details.
//
//     You should have received a copy of the GNU General Public License
//     along with this program.  If not, see <http://www.gnu.org/licenses/>
//
// Abm2Extensions.js
// Extensions for Amb2...
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguay.org)
// Paraguay Educa 2009
qx.Class.define("inventario.window.Abm2Extensions",
{
  extend : qx.core.Object,

  construct : function() {},

  statics :
  {
    launch : function(label, options, context)
    {
      var abm2 = new inventario.window.Abm2(null, inventario.widget.Url.getUrl(options.option), label);
      abm2.setPage(context._page);
      abm2.setShowAddButton(options.add);
      abm2.setShowModifyButton(options.modify);
      abm2.setShowDetailsButton(options.details);
      abm2.setShowDeleteButton(options.destroy);
      abm2.addCustomButtons(options.custom);
      abm2.launch();
    }
  }
});
