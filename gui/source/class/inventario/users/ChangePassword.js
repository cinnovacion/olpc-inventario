
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
// VerPerfil.js
// fecha: 2007-05-17
// autor: Kaoru Uchiyamada
//
//
/**
 * Constructor
 *
 * @param page {}  Puede ser null
 */
qx.Class.define("inventario.users.ChangePassword",
{
  extend : inventario.window.AbstractWindow,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function(page, oMethods)
  {
    inventario.window.AbstractWindow.call(this, page);
    this.prepared = false;
  },




  /*
    *****************************************************************************
       PROPERTIES
    *****************************************************************************
    */

  properties :
  {
    /*
         *  RPC
         */

    initialDataUrl :
    {
      check : "String",
      init  : "/perfiles/show"
    },

    saveDataUrl :
    {
      check : "String",
      init  : "/perfiles/change_password"
    },

    /*
         *  Objetos asociados
         */

    detalleObj :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /*
         * Widgets
         */

    vbox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /*
         * Inputs
         */

    /* Formulario de Recepcion */

    usuarioTextField :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    oldPwdTextField :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    newPwdTextField :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    confirmPwdTextField :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /*
         * Button
         */

    cambiarButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    }
  },




  /*
    *****************************************************************************
       MEMBERS
    *****************************************************************************
    */

  members :
  {
    /**
     * show():
     *
     * @return {void} void
     */
    show : function()
    {
      if (!this.prepared)
      {
        this._createInputs();  /* preparar widgets */
        this._setHandlers();
        this._createLayout();
      }

      /* traer datos  */

      this._loadInitialData();
    },


    /**
     * _doShow()
     *
     * @return {void} void
     */
    _doShow : function()
    {
      var page = this.getPage();
      page.setDimension("100%", "100%");
      inventario.widget.Layout.removeChilds(page);
      page.add(this.getVbox());
      page.add(this._buildCommandToolBar());

      qx.ui.core.Widget.flushGlobalQueues();
    },


    /**
     * _createInputs():  "Taggeamos" cada widget para que luego sea mas facil guardar
     *
     * @return {void} 
     */
    _createInputs : function()
    {
      var inputsOM = this.getInputsOM();

      if (inputsOM && inputsOM.length > 0) {
        inventario.widget.Form.resetInputs(inputsOM);
      }
      else
      {
        this._addPasswordField("oldPwd", "OldPwdTextField", true);
        this._addPasswordField("newPwd", "NewPwdTextField", true);
        this._addPasswordField("confirmPwd", "ConfirmPwdTextField", true);

        var h =
        {
          type            : "button",
          icon            : "edit_pen",
          text            : "Cambiar",
          callBackFunc    : this._saveData,
          callBackContext : this
        };

        this.getToolBarButtons().push(h);
      }
    },


    /**
     * _setHandlers():
     *
     * @return {void} 
     */
    _setHandlers : function() {},


    /**
     * _createLayout(): metodo abstracto
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var vbox = new qx.ui.layout.VerticalBoxLayout();
      vbox.setDimension("100%", "90%");
      this.setVbox(vbox);

      try
      {
        var gb = new qx.ui.groupbox.GroupBox("Cambio de Password");
        gb.setDimension("50%", "auto");
        var v = new qx.ui.layout.VerticalBoxLayout();
        v.setDimension("100%", "auto");

        gb.add(v);

        var gl = inventario.widget.Grid.createGridLayout(3, 2,
        {
          width         : "100%",
          height        : "auto",
          colArrayWidth : [ "50%", "50%" ]
        });

        gl.add(new qx.ui.basic.Atom("Viejo password:"), 0, 0);
        gl.add(this.getOldPwdTextField(), 1, 0);
        gl.add(new qx.ui.basic.Atom("Nuevo password:"), 0, 1);
        gl.add(this.getNewPwdTextField(), 1, 1);
        gl.add(new qx.ui.basic.Atom("Confirmar password:"), 0, 2);
        gl.add(this.getConfirmPwdTextField(), 1, 2);
        v.add(gl);

        vbox.add(gb);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("Error en el Groupbox\n" + e);
      }
    },


    /**
     * _loadInitialData(): metodo abstracto
     *
     * @return {void} 
     */
    _loadInitialData : function() {
      this._doShow();
    },

    //    var url = this.getInitialDataUrl();
    //    inventario.transport.Transport.callRemote({ url: url,parametros : null, handle: this._loadInitialDataResp,data: {}},this);
    /**
     * _loadInitialDataResp():
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadInitialDataResp : function(remoteData, params) {},

    //    this._doShow();
    /**
     * _validateData()
     * TODO falta implementar
     *
     * @return {void} 
     */
    _validateData : function()
    {
      this.payload =
      {
        old_pwd     : this.getOldPwdTextField().getValue(),
        new_pwd     : this.getNewPwdTextField().getValue(),
        confirm_pwd : this.getConfirmPwdTextField().getValue()
      };
    },


    /**
     * _saveData():
     *
     * @return {void} 
     */
    _saveData : function()
    {
      var url = this.getSaveDataUrl();
      this._validateData();
      var h = { payload : qx.util.Json.stringify(this.payload) };

      inventario.transport.Transport.callRemote(
      {
        url        : url,
        parametros : null,
        handle     : this._saveDataResp,
        data       : h
      },
      this);
    },


    /**
     * _saveDataResp(): retorno del RPC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _saveDataResp : function(remoteData, params) {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);
    }
  }
});