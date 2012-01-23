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

/* alert() replacement
 *  rgs
 *  2007/10/08
 */

qx.Class.define("inventario.window.Mensaje",
{
  extend : inventario.window.AbstractWindow,

  construct : function()
  {
    this.base(arguments);
    this.setAskConfirmationOnClose(false);
    this._prepared = false;
  },

  properties :
  {
    mensaje :
    {
      check : "String",
      init  : ""
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

    tituloPrincipal :
    {
      check : "String",
      init  : ""
    },

    tipoDeMensaje :
    {
      check : "String",
      init  : "info"
    },

    debuggingMsg :
    {
      check : "String",
      init  : ""
    },

    funcCallback :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    funcContext :
    {
      check    : "Object",
      init     : null,
      nullable : true
    }
  },

  statics :
  {
    mensaje : function(str, func, context, tituloVentana, tituloPrincipal, tipoDeMensaje, debuggingMsg)
    {
      var w = new inventario.window.Mensaje();

      if (tituloVentana) {
        w.setCaption(tituloVentana);
      }

      if (tituloPrincipal) {
        w.setTituloPrincipal(tituloPrincipal);
      }

      if (tipoDeMensaje) {
        w.setTipoDeMensaje(tipoDeMensaje);
      }

      if (debuggingMsg) {
        w.setDebuggingMsg(debuggingMsg.toString());
      }

      if (func)
      {
        w.setFuncCallback(func);

        if (context) {
          w.setFuncContext(context);
        }
      }

      w.setMensaje(str);
      w.launch();
    }
  },

  members :
  {
    launch : function()
    {
      if (!this._prepared)
        this._createLayout();

      this.open();
      this._button.focus();
    },

    _createLayout : function()
    {
      var vbox = this.getVbox()
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox());
      var image = null;

      switch(this.getTipoDeMensaje())
      {
        case "info":
          image = new qx.ui.basic.Image("inventario/22/idea.png");
          break;

        case "warning":
          image = new qx.ui.basic.Image("inventario/22/help.png");
          break;

        case "critical":
          image = new qx.ui.basic.Image("inventario/22/error.png");
          break;
      }

      if (image) {
        hbox.add(image);
      }

      this.setCaption(qx.locale.Manager.tr("Alert"));

      if (this.getTituloPrincipal() != "")
      {
        var str = this.getTituloPrincipal();
        var label = new qx.ui.basic.Label(str);
        label.setAllowGrowX(true);
        label.setTextAlign("center");
        hbox.add(label);
      }

      vbox.add(hbox, { flex : 1 });

      var scrollContainer = new qx.ui.container.Scroll();

      scrollContainer.set(
      {
        width  : 120,
        height : 120
      });

      var label = new qx.ui.basic.Label(this.getMensaje());
      label.setRich(true);
      label.setAllowGrowX(true);
      label.setAllowGrowY(true);

      scrollContainer.add(label);

      vbox.add(scrollContainer, { flex : 1 });

      var hbox_abajo = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));

      var caja_relleno_left = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      hbox_abajo.add(caja_relleno_left, { flex : 2 });

      var button_hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      this._button = new qx.ui.form.Button(qx.locale.Manager.tr("OK"), "inventario/16/button-ok.png");
      this._button.addListener("execute", this._accept_cb, this);
      button_hbox.add(this._button);

      hbox_abajo.add(button_hbox, { flex : 1 });

      if (this.getDebuggingMsg()) {
        var ver_codigo_button = new qx.ui.form.Button(qx.locale.Manager.tr("More info."), "inventario/16/comment.png");
        ver_codigo_button.addListener("execute", this._more_info_cb, this);
        hbox_abajo.add(ver_codigo_button);
      }

      var caja_relleno_right = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      hbox_abajo.add(caja_relleno_right, { flex : 2 });

      vbox.add(hbox_abajo, { flex : 1 });
      this._prepared = true;
    },

    _accept_cb : function()
    {
      var f = this.getFuncCallback();

      if (f) {
        var ctxt = this.getFuncContext();

        if (!ctxt) {
          ctxt = this;
        }

        f.call(ctxt);
      }

      this.close();
    },

    _more_info_cb : function() {
      inventario.window.Mensaje.mensaje(this.getDebuggingMsg());
    }
  }
});
