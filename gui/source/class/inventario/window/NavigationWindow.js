
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
/* NavigationWindow.js
 *  - Desplegar un mensaje y botones para saltar a otras ventanas
 *
 */

qx.Class.define("inventario.window.NavigationWindow",
{
  extend : inventario.window.AbstractWindow,

  construct : function(page)
  {
    inventario.window.AbstractWindow.call(this, page);

    this.setAbstractPopupWindowHeight(100);
    this.setAbstractPopupWindowWidth(400);
    this.setAskConfirmationOnClose(false);
    this.setUsePopup(true);

    this.setBotones(new Array());

    this._prepared = false;
  },

  properties :
  {
    mensaje :
    {
      check : "String",
      init  : ""
    },

    titulo :
    {
      check : "String",
      init  : ""
    },

    vbox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    borderColor :
    {
      check : "String",
      init  : "blue"
    },

    borderStyle :
    {
      check : "String",
      init  : "solid"
    },

    borderWidth :
    {
      check : "Number",
      init  : 2
    },

    botones :
    {
      check : "Object",
      init  : null
    },

    closeAfterCallback :
    {
      check : "Boolean",
      init  : false
    }
  },




  /*
    *****************************************************************************
       STATICS
    *****************************************************************************
    */

  members :
  {
    /**
     * TODOC
     *
     * @return {void} 
     */
    show : function()
    {
      if (!this._prepared) {
        this._createLayout();
      }

      var vbox = this.getVbox();
      this._doShow2(vbox);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var vbox = new qx.ui.layout.VerticalBoxLayout();
      vbox.setDimension("100%", "100%");
      vbox.setHorizontalChildrenAlign("center");

      var titulo = this.getTitulo();

      if (titulo != "") {
        this.setWindowTitle(titulo);
      }

      /*
             * Cuerpo del Mensaje
             */

      var label = new qx.ui.basic.Label(this.getMensaje());
      var b = new qx.ui.core.Border(this.getBorderWidth(), this.getBorderStyle(), this.getBorderColor());
      label.setWidth("90%");
      label.setHeight("50%");
      label.setBorder(b);
      vbox.add(label);

      /*
             * Botones
             */

      var buttons_hbox = new qx.ui.layout.HorizontalBoxLayout();
      buttons_hbox.setHorizontalChildrenAlign("center");
      buttons_hbox.setVerticalChildrenAlign("bottom");
      buttons_hbox.setDimension("100%", "20%");

      var len = this.getBotones().length;

      for (var i=0; i<len; i++)
      {
        var bstr = this.getBotones()[i]["button_text"];
        var f = this.getBotones()[i]["callback"];
        var ctxt = this.getBotones()[i]["callback_ctxt"];
        var b = new qx.ui.form.Button(bstr);
        b.setDimension("auto", "auto");
        this._registrarCallback(b, f, ctxt);

        buttons_hbox.add(b);

        var relleno = new qx.ui.layout.HorizontalBoxLayout();
        relleno.setDimension("10%", "100%");
        buttons_hbox.add(relleno);
      }

      vbox.add(buttons_hbox);

      this.setVbox(vbox);

      this._prepared = true;
    },


    /**
     * TODOC
     *
     * @param b {var} TODOC
     * @param f {Function} TODOC
     * @param ctxt {var} TODOC
     * @return {void} 
     */
    _registrarCallback : function(b, f, ctxt)
    {
      b.addListener("execute", function(e)
      {
        f.call(ctxt);

        if (this.getCloseAfterCallback()) {
          this.cerrar();
        }
      },
      this);
    }
  }
});