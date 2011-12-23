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
//
// Layout.js
//
qx.Class.define("inventario.widget.Layout",
{
  extend : qx.core.Object,

  construct : function() {},

  statics :
  {
    /**
     * removeChilds(): borrar childs (si los hay)
     *
     * @return {void} FIXME: esto genera un dispose? leaking?
     */
    removeChilds : function(widget)
    {
      try {
        var c = widget.getChildren();

        if (c && c.length > 0) {
          widget.removeAll();
        }
      } catch(e) {}
    }
  }
});
