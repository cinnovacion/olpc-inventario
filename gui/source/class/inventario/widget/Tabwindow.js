
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
// Tabwindow.js
// fecha: 2006-12-02
// autor: Raul Gutierrez S. - rgs@fuzzylogic.com.py
//
// Pantalla con pestanhas
//
// TODO:
// - esto deberia heredar de AbstractWindow
//
qx.Class.define("inventario.widget.Tabwindow",
{
  extend : inventario.window.AbstractWindow,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function() {
    inventario.window.AbstractWindow.call(this, null);
  },




  /*
    *****************************************************************************
       PROPERTIES
    *****************************************************************************
    */

  properties :
  {
    tabItems : { check : "Object" },
    tabBar   : { check : "Object" }
  },




  /*
    *****************************************************************************
       MEMBERS
    *****************************************************************************
    */

  members :
  {
    /**
     * show(): estamos al aire
     *
     * @return {void} void
     */
    show : function()
    {
      var tabItems = this.getTabItems();
      var tb = inventario.widget.Layout.createTabBar(tabItems);
      this.setTabBar(tb);

      var vbox = new qx.ui.layout.VerticalBoxLayout();
      vbox.setDimension("100%", "100%");
      vbox.add(tb);

      // vbox.setOverflow("auto");
      this._doShow2(vbox);

      /*
             * Verificar si hay alguna pagina que activar
             */

      var len = tabItems.length;
      var bar = tb.getBar();
      var pane = tb.getPane();
      bar.setDimension("auto", "auto");

      for (var i=0; i<len; i++)
      {
        var h = tabItems[i];

        if (h.checked)
        {
          bar.getChildren()[i].setValue(true);

          /*
                     * HACK: viola la encapsulacion
                     */

          h.handler.call(h.obj);
          break;
        }
      }
    }
  }
});
