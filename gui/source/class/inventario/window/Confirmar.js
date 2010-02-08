
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
/* Reemplazo de confirm()
 *  rgs
 *  2007/10/08
 */

qx.Class.define("inventario.window.Confirmar",
{
  extend : inventario.window.AbstractWindow,

  construct : function(page)
  {
    inventario.window.AbstractWindow.call(this, page);

    this.setAbstractPopupWindowHeight(100);
    this.setAbstractPopupWindowWidth(400);
    this.setAskConfirmationOnClose(false);
    this.setUsePopup(true);

    this._prepared = false;
  },

  properties :
  {
    mensaje :
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

    tituloPrincipal :
    {
      check : "String",
      init  : "Alerta"
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

    funcYesCallback :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    funcYesContext :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    funcNoCallback :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    funcNoContext :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    botonSiTexto :
    {
      check : "String",
      init  : "Si"
    },

    botonNoTexto :
    {
      check : "String",
      init  : "No"
    }
  },




  /*
    *****************************************************************************
       STATICS
    *****************************************************************************
    */

  statics :
  {
    /**
     * TODOC
     *
     * @param msgConfirmacion {var} TODOC
     * @param funcYes {var} TODOC
     * @param contextYes {var} TODOC
     * @param funcNo {var} TODOC
     * @param contextNo {var} TODOC
     * @param winTitle {var} TODOC
     * @return {void} 
     */
    confirmar : function(msgConfirmacion, funcYes, contextYes, funcNo, contextNo, winTitle)
    {
      var w = new inventario.window.Confirmar();

      if (winTitle) {
        w.setWindowTitle(winTitle);
      }

      if (funcYes)
      {
        w.setFuncYesCallback(funcYes);

        if (contextYes) {
          w.setFuncYesContext(contextYes);
        }
      }

      if (funcNo)
      {
        w.setFuncNoCallback(funcNo);

        if (contextNo) {
          w.setFuncNoContext(contextNo);
        }
      }

      w.setMensaje(msgConfirmacion);
      w.show();
    }
  },

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

      /*
            * Titulo & Imagen de tipo de mensaje
            */

      var hbox = new qx.ui.layout.HorizontalBoxLayout();
      hbox.setHorizontalChildrenAlign("center");
      hbox.setDimension("100%", "20%");
      var image = null;

      switch(this.getTipoDeMensaje())
      {
        case "info":
          image = new qx.ui.basic.Image("aisa/image/22/idea.png");
          break;

        case "warning":
          image = new qx.ui.basic.Image("aisa/image/22/help.png");
          break;

        case "critical":
          image = new qx.ui.basic.Image("aisa/image/22/error.png");
          break;
      }

      if (image) {
        hbox.add(image);
      }

      vbox.add(hbox);

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
             * Confirmar/Cancelar
             */

      var button_hbox = new qx.ui.layout.HorizontalBoxLayout();
      button_hbox.setHorizontalChildrenAlign("center");
      button_hbox.setVerticalChildrenAlign("bottom");
      button_hbox.setDimension("100%", "20%");

      var button_yes = new qx.ui.form.Button(this.getBotonSiTexto(), "aisa/image/16/button-ok.png");
      button_yes.setDimension("auto", "auto");

      button_yes.addListener("execute", function()
      {
        var f = this.getFuncYesCallback();

        if (f)
        {
          var ctxt = this.getFuncYesContext();

          if (!ctxt) {
            ctxt = this;
          }

          f.call(ctxt);
        }

        this.getAbstractPopupWindow().getWindow().close();
      },
      this);

      button_hbox.add(button_yes);

      var relleno = new qx.ui.layout.HorizontalBoxLayout();
      relleno.setDimension("10%", "100%");
      button_hbox.add(relleno);

      var button_no = new qx.ui.form.Button(this.getBotonNoTexto(), "aisa/image/16/button-cancel.png");
      button_no.setDimension("auto", "auto");

      button_no.addListener("execute", function()
      {
        var f = this.getFuncNoCallback();

        if (f)
        {
          var ctxt = this.getFuncNoContext();

          if (!ctxt) {
            ctxt = this;
          }

          f.call(ctxt);
        }

        this.getAbstractPopupWindow().getWindow().close();
      },
      this);

      button_hbox.add(button_no);

      vbox.add(button_hbox);
      this.setVbox(vbox);

      this._prepared = true;
    }
  }
});