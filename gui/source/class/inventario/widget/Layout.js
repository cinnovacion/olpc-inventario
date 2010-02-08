
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
// fecha: 2006-11-21
// autor: Raul Gutierrez S. - rgs@fuzzylogic.com.py
//
// creacion de barras de menu y contenedores de pantalla
//
qx.Class.define("inventario.widget.Layout",
{
  extend : qx.core.Object,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function() {},

  // llamar al constructor del padre
  /*
    *****************************************************************************
       STATICS
    *****************************************************************************
    */

  statics :
  {
    /**
     * createMenuBar(): crea una barra de menu teniendo en cuenta los privilegios
     *
     * @param menuItems {var} vector de hashes { label,icon,handler,obj,checked }
     * @param disposition {var} TODOC
     * @return {var} qx.ui.pageview.buttonview.ButtonView
     */
    createMenuBar : function(menuItems, disposition)
    {
      var bs = new qx.ui.pageview.buttonview.ButtonView;
      var vBsb = new Array();
      var len = menuItems.length;

      bs.set(
      {
        left   : 0,
        top    : 0,
        right  : 0,
        bottom : 0
      });

      try
      {
        bs.allowStretchX = true;
        bs.allowStretchY = true;
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje(e);
      }

      bs.setBarPosition(disposition);

      for (var i=0; i<len; i++)
      {
        var label = menuItems[i].label;
        var icon = menuItems[i].icon;
        var obj = menuItems[i].obj;
        var handler = menuItems[i].handler;
        var tooltip = menuItems[i].tooltip;
        var mensaje_activacion = menuItems[i].mensaje_activacion;

        var but = new qx.ui.pageview.buttonview.Button(label, icon);

        if (tooltip) {
          but.setToolTip(new qx.ui.popup.ToolTip(tooltip));
        }

        vBsb.push(but);

        if (menuItems[i].checked) {
          vBsb[i].setValue(true);
        }

        vBsb[i].set(
        {
          iconPosition            : "left",
          horizontalChildrenAlign : "left"
        });

        bs.getBar().add(vBsb[i]);

        var p = new qx.ui.pageview.buttonview.Page(vBsb[i]);

        if (handler)
        {
          if (obj) {
            obj.setPage(p);
          }

          p.getButton().addListener("click", handler, obj);
          p.getButton().setUserData("funcion_handler", handler);
          p.getButton().setUserData("funcion_handler_obj", obj);

          if (mensaje_activacion)
          {
            qx.event.message.Bus.subscribe(mensaje_activacion, function(msg)
            {
              this.setValue(true);
              var f = this.getUserData("funcion_handler");
              var obj = this.getUserData("funcion_handler_obj");
              f.call(obj);
            },
            p.getButton());
          }
        }

        bs.getPane().add(p);
      }

      bs.getBar().setHorizontalChildrenAlign("center");
      bs.getBar().setVerticalChildrenAlign("top");
      bs.getBar().setBackgroundColor("#DADADA");

      // bs.getBar().setBackgroundImage("aisa/image/fondo_inventario.png");
      return bs;
    },


    /**
     * uncheckedMenuBarItems(): desactiva los items de la barra de menu lateral
     *
     * @param menuBar {qx.ui.pageview.buttonview.ButtonView} TODOC
     * @return {void} 
     */
    uncheckedMenuBarItems : function(menuBar)
    {
      var menuItems = new Array();
      var len;

      len = menuBar.getBar().getChildren().length;

      for (var i=0; i<len; i++)
      {
        if (menuBar.getBar().getChildren()[i].getChecked()) {
          menuBar.getBar().getChildren()[i].setValue(false);
        }
      }
    },


    /**
     * createTabBar(): crea una barra de tabs segun los privilegios
     *
     * @param tabItems {Array} vector de hashes { label,icon,handler,obj,checked }
     * @return {qx.ui.pageview.tabview.TabView} TODOC
     */
    createTabBar : function(tabItems)
    {
      var tv = new qx.ui.pageview.tabview.TabView;
      var tvb = new Array();
      var len = tabItems.length;

      tv.setDimension("100%", "100%");
      tv.setLeft(10);

      for (var i=0; i<len; i++)
      {
        var h = tabItems[i];
        var t = new qx.ui.pageview.tabview.Button(h.label);
        var p = new qx.ui.pageview.tabview.Page(t);

        if (h.handler)
        {
          if (h.obj) {
            h.obj.setPage(p);
          }

          p.getButton().addListener("click", h.handler, h.obj);
        }

        tv.getPane().add(p);
        tv.getBar().add(t);
      }

      tv.getBar().setHorizontalChildrenAlign("center");
      tv.getBar().setVerticalChildrenAlign("top");

      return tv;
    },


    /**
     * removeChilds(): borrar childs (si los hay)
     *
     * @param widget {Object} TODOC
     * @return {void} FIXME: esto genera un dispose? leaking?
     */
    removeChilds : function(widget)
    {
      try
      {
        var c = widget.getChildren();

        if (c && c.length > 0) {
          widget.removeAll();
        }
      }
      catch(e) {}
    }
  }
});
