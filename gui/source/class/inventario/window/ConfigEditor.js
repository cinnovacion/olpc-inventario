
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
// ConfigEditor.js
// fecha: 2007-02-08
// autor: Raul Gutierrez S.
//
// Manipular parametros del sistema a traves de grupos de clave/valor
//
/**
 * Esta clase utiliza 3 metodos:
 *
 * 1) saveConfigUrl
 * 2) getConfigUrl
 * 3) listConfigUrl
 *
 *
 * @param page {}  Puede ser null
 * @param oMethods {Hash}  hash de configuracion {searchUrl,initialDataUrl}
 * @return void
 */
qx.Class.define("inventario.window.ConfigEditor",
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

    /* Parametros funcionales */

    paginated :
    {
      check : "Boolean",
      init  : false
    },

    title :
    {
      check : "String",
      init  : "Buscador"
    },

    /*
         *  RPC
         */

    saveConfigUrl :
    {
      check : "String",
      init  : "/config/save_config"
    },

    getConfigUrl :
    {
      check : "String",
      init  : "/config/get_config"
    },

    listConfigUrl :
    {
      check : "String",
      init  : "/config/list_configs"
    },

    /* ayuda on-line */

    helpUrl :
    {
      check : "String",
      init  : "/ayuda/get_text"
    },

    helpText :
    {
      check : "String",
      init  : "config"
    },

    /*
         *  Widgets & Inputs
         */

    /* secciones de pantalla */

    groupBox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    verticalBox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    hboxHelp :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    hboxA :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    hboxB :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    hboxC :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /* grilla */

    grid :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /* input fields & buttons */

    configNameInput :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    saveConfigButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    helpButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    listComboBox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    loadConfigButton :
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
     * show(): vemos si ya esta todo preparado o aun no se armo la ventana. De esta forma se demora el RPC hasta el primer evento
     *         que nos llama y tambien queda todo (objetos y datos venidos del servidor) cacheados p/ la proximas veces.
     *
     * @return {void} void
     */
    show : function()
    {

      /* preparar widgets */

      this._createInputs();

      if (!this.prepared)
      {
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
      var gb = this.getGroupBox();

      /* page.removeAll();    */

      page.add(gb);

      this._createGrid(10, 2, []);
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
      var w = this.getConfigNameInput();

      if (w)
      {
        var inputs = new Array();

        /* cerar inputs, ya estan creados */

        inputs.push(w);

        /* hack-cito: si hay inputs la tabla puede q este.. borrarla */

        this._removeGrid();
        inventario.widget.Form.resetInputs(inputs);
      }
      else
      {
        var but = new qx.ui.form.Button("Guardar");
        this.setSaveConfigButton(but);

        var but = new qx.ui.form.Button("Ayuda");
        this.setHelpButton(but);

        /* este no cero pq se va a cerar via loadInitialData() */

        var cb = new qx.ui.form.SelectBox();
        this.setListComboBox(cb);

        var but = new qx.ui.form.Button("Cargar");
        this.setLoadConfigButton(but);

        var input = new qx.ui.form.TextField();
        this.setConfigNameInput(input);
      }
    },


    /**
     * setHandlers():
     * 
     * Aqui hay que establecer interacciones entre inputs,botones & validaciones
     *
     * @return {void} 
     */
    _setHandlers : function()
    {
      var but = this.getSaveConfigButton();

      but.addListener("execute", function(e)
      {
        try
        {
          this._validateData();
          this._saveData();
        }
        catch(e)
        {
          inventario.window.Mensaje.mensaje("Error al intentar guardar el config: " + e);
        }
      },
      this);

      var but = this.getHelpButton();

      but.addListener("execute", function(e)
      {
        var helpobj = this.getHelpObj();

        if (!helpobj)
        {
          var tu = this.getHelpUrl();
          var hn = this.getHelpText();

          var hopt =
          {
            textUrl  : tu,
            helpName : hn
          };

          helpobj = new inventario.window.HelpWindow(hopt);
          this.setHelpObj(helpobj);
        }

        helpobj.show();
      },
      this);

      /* Cargar Grilla p/ edicion */

      var but = this.getLoadConfigButton();

      but.addListener("execute", function(e)
      {
        try
        {
          var cb = this.getListComboBox();
          var config_id = inventario.widget.Form.getInputValueValidated(cb, "Grupo de Parametros invalido", "combobox", "");
          var opts = {};
          opts["url"] = this.getGetConfigUrl();
          opts["parametros"] = null;
          opts["handle"] = this._loadConfig;
          opts["data"] = { config_id : config_id };
          inventario.transport.Transport.callRemote(opts, this);
        }
        catch(e)
        {
          inventario.window.Mensaje.mensaje(e);
        }
      },
      this);
    },


    /**
     * createLayout(): metodo abstracto
     * 
     * Posicionamiento de inputs
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var gb = new qx.ui.groupbox.GroupBox("Editor de Configuraciones");
      this.setGroupBox(gb);
      gb.setDimension("100%", "100%");
      this.getPage().add(gb);

      var vbox = new qx.ui.layout.VerticalBoxLayout;
      vbox.setDimension("100%", "100%");
      vbox.setHorizontalChildrenAlign("center");
      this.setVerticalBox(vbox);

      /*
             *  Botones de ayuda (futuramente una barra)
             */

      try
      {
        var h = new qx.ui.layout.HorizontalBoxLayout();
        h.setDimension("100%", "auto");
        h.setHorizontalChildrenAlign("right");
        h.add(this.getHelpButton());
        this.setHboxHelp(h);
        vbox.add(h);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje(" Problemas al agregar botones de ayuda,etc." + e);
      }

      /*
             *  Grilla de claves/valor
             */

      try
      {
        var hbox = new qx.ui.layout.HorizontalBoxLayout();
        hbox.setDimension("75%", "75%");
        hbox.setHorizontalChildrenAlign("center");
        this.setHboxB(hbox);

        vbox.add(hbox);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("Problemas al crear la segunda parte " + e);
      }

      /*
             * Cargar y/o Guardar
             */

      try
      {
        var v = new qx.ui.layout.VerticalBoxLayout();
        v.setDimension("100%", "auto");
        v.setVerticalChildrenAlign("bottom");
        v.setBottom(20);
        v.setHorizontalChildrenAlign("center");
        this.setHboxC(v);

        var gl = inventario.widget.Grid.createGridLayout(2, 3,
        {
          width         : "50%",
          height        : "auto",
          colArrayWidth : [ "20%", "60%", "20%" ]
        });

        gl.setBottom(20);

        /*
                 * Cargar planilla para editar
                 */

        var l = new qx.ui.basic.Atom("Configuraciones:");
        gl.add(l, 0, 0);
        gl.add(this.getListComboBox(), 1, 0);
        gl.add(this.getLoadConfigButton(), 2, 0);

        /*
                 *  Guardar planilla nueva o sobreescribir la que se edito
                 */

        var l = new qx.ui.basic.Atom("Nombre de Grupo:");
        gl.add(l, 0, 1);
        gl.add(this.getConfigNameInput(), 1, 1);
        gl.add(this.getSaveConfigButton(), 2, 1);

        v.add(gl);

        vbox.add(v);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("Problemas al crear la tercera parte " + e);
      }

      gb.add(vbox);
    },


    /**
     * loadInitialData(): traemos planillas existentes
     *
     * @return {void} 
     */
    _loadInitialData : function()
    {
      var opts = {};
      opts["url"] = this.getListConfigUrl();
      opts["parametros"] = null;
      opts["handle"] = this._loadInitialDataResp;
      opts["data"] = {};
      inventario.transport.Transport.callRemote(opts, this);
    },


    /**
     * _loadInitialDataResp():  cargar planillas existentes
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadInitialDataResp : function(remoteData, params)
    {
      var cb = this.getListComboBox();
      inventario.widget.Form.loadComboBox(cb, remoteData.configs, true);

      this._doShow();
      this.prepared = true;
    },


    /**
     * validateData(): metodo abstracto
     *
     * @return {void} 
     * @throws TODOC
     */
    _validateData : function()
    {
      this._saveConfig = this.getTableObj().getData();

      if (this._saveConfig.length == 0) {
        throw new Error("Debe establecer al menos un par clave/valor!");
      }

      var configuracionNombre = this.getConfigNameInput().getValue();

      if (configuracionNombre && configuracionNombre != "" && !configuracionNombre.match(" ")) {
        this._configuracionNombre = configuracionNombre;
      } else {
        throw new Error("Debe proveer un nombre a la configuracion");
      }
    },


    /**
     * saveData(): guardar Planilla, JSON-ificar,send
     *
     * @return {void} 
     */
    _saveData : function()
    {
      if (confirm("Guardar Parametros?"))
      {

        /* Json-ificar y enviar */

        var opts = {};
        opts["url"] = this.getSaveConfigUrl();
        opts["parametros"] = null;
        opts["handle"] = this._saveDataResp;

        opts["data"] =
        {
          config : qx.util.Json.stringify(this._saveConfig),
          nombre : this._configuracionNombre
        };

        inventario.transport.Transport.callRemote(opts, this);
      }
    },


    /**
     * saveDataResp(): Se guardo OK?
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} 
     */
    _saveDataResp : function(remoteData, handleParams)
    {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);

      if (remoteData["result"] == "ok")
      {

        /* Ya que estamos vamos a refrescar la lista de configuraciones */

        var cb = this.getListComboBox();
        inventario.widget.Form.loadComboBox(cb, remoteData.configs, true);
      }
    },


    /**
     * _loadConfig(): cargar una config para edicion
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} void
     */
    _loadConfig : function(remoteData, handleParams)
    {
      var g = remoteData["config"];
      var row_num = g.length;
      var col_num = (row_num > 0) ? g[0].length : 0;
      this._createGrid(row_num, col_num, g);

      /*
             * Establecer el nombre de la planilla q esta siendo editada
             */

      var n = this.getListComboBox().getField().getValue();
      this.getConfigNameInput().setValue(n);
    },


    /**
     * _createGrid(): crear tabla
     *
     * @param numRows {var} TODOC
     * @param numCols {var} TODOC
     * @param grid {var} TODOC
     * @return {void} void
     */
    _createGrid : function(numRows, numCols, grid)
    {
      this._removeGrid();

      var col_titles = [ "Nombre", "Valor" ];
      var editables = [ true, true ];
      var widths = [ 200, 200 ];

      /*
             * FIXME: Habria que hacer un dispose de TableObj!
             */

      var tableObj = new inventario.widget.Table2();
      tableObj.setButtonsAlignment("center");
      tableObj.setTitles(col_titles);
      tableObj.setEditables(editables);
      tableObj.setWidths(widths);

      if (!grid || (grid && grid.length == 0)) {
        tableObj.setUseEmptyTable(true);
      } else {
        tableObj.setGridData(grid);
      }

      tableObj.setShowModifyButton(false);
      tableObj.setRowsNum(10);
      tableObj.setColsNum(col_titles.length);
      tableObj.setPage(this.getHboxB());

      tableObj.show();

      var but = tableObj.getAddButton();

      but.addListener("execute", function(e) {
        this.getTableObj().addEmptyRow();
      }, this);

      this.setTableObj(tableObj);
    },


    /**
     * _removeGrid(): si habia una tabla, hacerla desaparecer
     *
     * @return {void} void
     */
    _removeGrid : function() {
      inventario.widget.Layout.removeChilds(this.getHboxB());
    }
  }
});