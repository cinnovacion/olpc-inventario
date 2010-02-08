
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
qx.Class.define("inventario.users.VerPerfil",
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
      init  : "/perfiles/save"
    },

    addUrl :
    {
      check : "String",
      init  : "/perfiles/new"
    },

    saveUrl :
    {
      check : "String",
      init  : "/perfiles/save"
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
         * Button
         */

    entregarButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    cargarButton :
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
      } else {}
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
    },


    /**
     * _loadInitialData(): metodo abstracto
     *
     * @return {void} 
     */
    _loadInitialData : function()
    {
      var url = this.getInitialDataUrl();

      inventario.transport.Transport.callRemote(
      {
        url        : url,
        parametros : null,
        handle     : this._loadInitialDataResp,
        data       : {}
      },
      this);
    },


    /**
     * _loadInitialDataResp():
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadInitialDataResp : function(remoteData, params)
    {
      if (!this.prepared)
      {
        var gb = new qx.ui.groupbox.GroupBox("Perfiles");
        gb.setDimension("50%", "auto");
        var v = new qx.ui.layout.VerticalBoxLayout;
        v.setDimension("100%", "auto");

        gb.add(v);

        var datos = remoteData["data"];
        var len = datos.length;

        var gl = inventario.widget.Grid.createGridLayout(len, 2,
        {
          width         : "100%",
          height        : "auto",
          colArrayWidth : [ "50%", "50%" ]
        });

        for (var i=0; i<len; i++)
        {
          gl.add(new qx.ui.basic.Atom(datos[i].text), 0, i);
          gl.add(new qx.ui.basic.Atom(datos[i].value), 1, i);
        }

        v.add(gl);

        this.getVbox().add(gb);

        var h =
        {
          type : "button",
          icon : "floppy_black",
          text : "Modificar",

          callBackFunc : function() {
            this._addRow(0, false);
          },

          callBackContext : this
        };

        this.getToolBarButtons().push(h);

        this.prepared = true;
      }

      this._doShow();
    },


    /**
     * _validateData()
     * TODO falta implementar
     *
     * @return {void} 
     */
    _validateData : function() {
      this.payload = {};
    },


    /**
     * _saveData():
     *
     * @return {void} 
     */
    _saveData : function()
    {
      var url = this.getSaveDataUrl();
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
    },


    /**
     * TODOC
     *
     * @param editRow {var} TODOC
     * @param details {var} TODOC
     * @return {void} 
     */
    _addRow : function(editRow, details)
    {
      var add_form = new inventario.window.AbmForm(null, {});
      add_form.setWindowCaption("Modificar Perfil");
      add_form.setEditRow(editRow);
      add_form.setDetails(details);
      add_form.setSaveCallback(this._addRowHandler);
      add_form.setSaveCallbackObj(this);
      var url = this.getAddUrl();
      add_form.setInitialDataUrl(url);
      var url = this.getSaveUrl();
      add_form.setSaveUrl(url);
      add_form.show();
    },


    /**
     * TODOC
     *
     * @param filaAgregada {var} TODOC
     * @param remoteData {var} TODOC
     * @return {void} 
     */
    _addRowHandler : function(filaAgregada, remoteData)
    {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);

      if (remoteData["id"])
      {
        // no se para que sirve esta variable, dsp se tendria que sacar
        this._searchMode = true;
        this.queryStr = remoteData["id"];

        // aca suponemos que siempre el primer items de select es el id
        this.queryOption = this.getSearchOptions().getList().getFirstChild().getValue();
      }

      this.prepared = false;
      this.show();
    }
  }
});