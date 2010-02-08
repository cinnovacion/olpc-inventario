
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
// Detalles.js
// fecha: 2007-03-30
// autor: Kaoru Uchiyamada
//
/**
 * @param page {}  Puede ser null
 * @param oMethods {Hash}  hash de configuracion {searchUrl,initialDataUrl}
 * @return void
 */
qx.Class.define("inventario.window.Detalles",
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
    this.setInitialDataUrl(oMethods.initialDataUrl);
    this.setAskConfirmationOnClose(false);
    this.setUsePopup(true);
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
         *  Widgets & Inputs
         */

    /* secciones de pantalla */

    gridLayout :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /*
         * Objetos auxiliares: ventana de ayuda,etc.
         */

    helpObj :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    tableObj :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    tableHbox : { check : "Object" },

    vbox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    title :
    {
      check : "String",
      init  : "Detalles"
    },

    icon :
    {
      check : "String",
      init  : "icon/16/devices/video-display.png"
    },

    initialDataUrl :
    {
      check : "String",
      init  : "/encargado_de_deposito/entregar"
    },

    height :
    {
      check : "Number",
      init  : 450
    },

    width :
    {
      check : "Number",
      init  : 500
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
     * @param purchase_order_id {var} TODOC
     * @return {void} void
     */
    show : function(purchase_order_id)
    {
      this._createInputs();  /* preparar widgets */

      if (!this.prepared)
      {
        this._setHandlers();
        this._createLayout();
        this._loadInitialData();  /* traer impuestos  */
      }
      else
      {
        this._doShow();
      }
    },


    /**
     * _doShow()
     *
     * @return {void} void
     *   
     *     TODO: El objeto winObj podriamos reciclar..
     */
    _doShow : function()
    {
      var height = this.getHeight();
      var width = this.getWidth();
      this.setAbstractPopupWindowHeight(height);
      this.setAbstractPopupWindowWidth(width);
      this.setWindowTitle(this.getTitle());

      this._doShow2(this.getGridLayout());
      this.getTableObj().show();
    },


    /**
     * createInputs():
     * 
     *  - Cerar widgets si ya existen
     *
     * @return {void} 
     */
    _createInputs : function()
    {
      if (this.prepared)
      {
        if (!filaEdicion || (filaEdicion && filaEdicion.length == 0)) {
          this._resetInputs();
        }
      }
    },


    /**
     * setHandlers():
     * 
     * Aqui hay que establecer interacciones entre inputs,botones & validaciones
     *
     * @return {void} 
     */
    _setHandlers : function() {},


    /**
     * createLayout():
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var vbox = new qx.ui.layout.VerticalBoxLayout;
      vbox.setDimension("100%", "100%");
      this.setVbox(vbox);

      try
      {
        var h1 = new qx.ui.layout.VerticalBoxLayout();
        h1.setWidth("100%");
        h1.setHeight("90%");

        var h2 = new qx.ui.layout.HorizontalBoxLayout();
        h2.setWidth("100%");
        h2.setHeight("90%");
        this.setTableHbox(h2);

        h1.add(h2);
        vbox.add(h1);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("Problemas con la seccion para la tabla\n" + e);
      }
    },


    /**
     * loadInitialData(): traer impuestos
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
     * _loadInitialDataResp():  cargar combobox de impuestos
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadInitialDataResp : function(remoteData, params)
    {
      if (!this.prepared)
      {
        /*
                 * Crear objeto tabla y cargar detalles de factura
                 */

        try
        {
          var tableObj = new inventario.widget.Table2();
          tableObj.setTitles(remoteData["col_titles"]);
          tableObj.setEditables(remoteData["editables"]);
          tableObj.setWidths(remoteData["widths"]);
          tableObj.setPage(this.getTableHbox());
          tableObj.setUseEmptyTable(true);
          tableObj.setRowsNum(5);
          tableObj.setColsNum(remoteData["col_titles"].length);
          tableObj.setButtonsAlignment("center");
          tableObj.getHashKeys().push(remoteData["keys"]);
          tableObj.setWithButtons(false);
          tableObj.setGridData(remoteData["rows"]);

          this.setTableObj(tableObj);
          this.getTableObj().show();
          var lay = new qx.ui.layout.VerticalBoxLayout();
          lay.setDimension("auto", "auto");
          lay.add(this.getTableObj().getGrid());
          this.setGridLayout(lay);

          this.prepared = true;
        }
        catch(e)
        {
          inventario.window.Mensaje.mensaje("Detalles._loadInitialDataResp =>" + e);
        }
      }

      this._doShow();
    },


    /**
     * validateData(): metodo abstracto
     *
     * @return {void} 
     */
    _validateData : function() {}
  }
});