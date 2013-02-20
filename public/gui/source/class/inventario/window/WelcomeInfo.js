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
// WelcomeInfo.js
//
// date: 2008-12-28
// author: Raul Gutierrez S.
//
//
qx.Class.define("inventario.window.WelcomeInfo",
{
  extend : qx.ui.container.Composite,

  construct : function() {
    this._vbox = new qx.ui.layout.HBox(20);
    var spacer = new qx.ui.core.Spacer();
    var img    = new qx.ui.basic.Image(this.getDefaultLogoPath());

    this.base(arguments, this._vbox);
    this.setBackgroundColor('#FFFFFF');
    this.add(img, { flex : 1 });
    this.add(spacer, { flex : 2});
    this.add(this.spotlight(), { flex : 1 });
  },

  properties :
  {
    defaultLogoPath :
    {
      check : "String",
      init  : "/images/view_by_name/logo_pyeduca.jpg"
    },

    menuElements :
    {
      check : "Object",
      init  : []
    }

  },

  members :
  {
    // Perhaps we should check if menu elements was given to us in order 
    // to instantiate Autocomplete?
    spotlight : function() {
        var autocomplete = new inventario.widget.Autocomplete();
        var spotlight    = new qx.ui.container.Stack();
        var container    = new qx.ui.container.Composite(new qx.ui.layout.VBox(5));
        container.add(new qx.ui.basic.Label(qx.locale.Manager.tr("Quick access")));
        autocomplete.setAutocompleteElements(this.getMenuElements());
        container.add(autocomplete);
        spotlight.setMaxWidth(200);
        spotlight.setAlignX('right');
        spotlight.setAlignY('top');
        spotlight.add(container);
        return spotlight;
    }
  }
});
