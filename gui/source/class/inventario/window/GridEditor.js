
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
// GridEditor.js
// fecha: 2007-01-10
// autor: Raul Gutierrez S.
//
// Crear una planilla de formulas
//
//
//  TODO: falta poder borrar filas (la seleccionada) y columna (la ultima)
//
/**
 * Esta clase utiliza 3 metodos:
 *
 * 1) saveGridUrl
 * 2) getGridUrl
 * 3) listGridUrl
 *
 *
 * @param page {}  Puede ser null
 * @param oMethods {Hash}  hash de configuracion {searchUrl,initialDataUrl}
 * @return void
 */
qx.Class.define("inventario.window.GridEditor",
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

    /* Cargar parametros sinhe quae non */

    try
    {
      this.setSaveGridUrl(oMethods.saveGridUrl);
      this.setGetGridUrl(oMethods.getGridUrl);
      this.setListGridUrl(oMethods.listGridUrl);
    }
    catch(e)
    {
      inventario.window.Mensaje.mensaje("Falta un parametro en el hash de urls! " + e);
    }
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

    saveGridUrl :
    {
      check : "String",
      init  : ""
    },

    getGridUrl :
    {
      check : "String",
      init  : ""
    },

    listGridUrl :
    {
      check : "String",
      init  : ""
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
      init  : "grid"
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

    rowInput :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    colInput :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    eliminarInput :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    eliminarColumnaButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    eliminarFilaButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    createGridButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    gridNameInput :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    saveGridButton :
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

    loadGridButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    addRowButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    addColButton :
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
      var w = this.getRowInput();

      if (w)
      {
        var inputs = new Array();

        /* cerar inputs, ya estan creados */

        inputs.push(w);
        inputs.push(this.getColInput());
        inputs.push(this.getEliminarInput());
        inputs.push(this.getGridNameInput());

        /* hack-cito: si hay inputs la tabla puede q este.. borrarla */

        this._removeGrid();
        inventario.widget.Form.resetInputs(inputs);
      }
      else
      {
        var rowInput = new qx.ui.form.TextField();
        this.setRowInput(rowInput);

        var colInput = new qx.ui.form.TextField();
        this.setColInput(colInput);

        var eliminarInput = new qx.ui.form.TextField();
        this.setEliminarInput(eliminarInput);

        var but = new qx.ui.form.Button("Crear Planilla");
        this.setCreateGridButton(but);

        var i = new qx.ui.form.TextField();
        this.setGridNameInput(i);

        var but = new qx.ui.form.Button("Guardar Planilla");
        this.setSaveGridButton(but);

        var but = new qx.ui.form.Button("Ayuda");
        this.setHelpButton(but);

        /* este no cero pq se va a cerar via loadInitialData() */

        var cb = new qx.ui.form.SelectBox();
        this.setListComboBox(cb);

        var but = new qx.ui.form.Button("Cargar");
        this.setLoadGridButton(but);

        var but = new qx.ui.form.Button("Agregar Fila");
        this.setAddRowButton(but);

        var but = new qx.ui.form.Button("Agregar Columna");
        this.setAddColButton(but);

        var but = new qx.ui.form.Button("Eliminar Columna");
        this.setEliminarColumnaButton(but);

        var but = new qx.ui.form.Button("Eliminar Fila");
        this.setEliminarFilaButton(but);
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
      var but = this.getCreateGridButton();

      /* Crear Grilla */

      but.addListener("execute", function(e)
      {
        try
        {
          var col_num = this.getColInput().getValue();

          if (!parseInt(col_num))
          {
            inventario.window.Mensaje.mensaje("El numero de columnas es invalido");
            return false;
          }
          else
          {
            col_num = parseInt(col_num);
          }

          var fila_num = this.getRowInput().getValue();

          if (!parseInt(fila_num))
          {
            inventario.window.Mensaje.mensaje("El numero de filas es invalido");
            return false;
          }
          else
          {
            fila_num = parseInt(fila_num);
          }

          this._createGrid(fila_num, col_num, []);
        }
        catch(e)
        {
          inventario.window.Mensaje.mensaje("Error al intentar crear la grilla" + e);
        }
      },
      this);

      /* Agrega fila a la  Grilla */

      var but = this.getAddRowButton();

      but.addListener("execute", function(e)
      {

        /* obtener dimension & datos actuales */

        var g = this.getGrid();

        if (g)
        {
          var datos = g.getTableModel().getData();
          var num_filas = datos.length;
          var num_columnas = (num_filas > 0) ? datos[0].length : 0;
          var newRow = new Array();

          for (var i=0; i<num_columnas; i++) {
            newRow.push("");
          }

          datos.push(newRow);  /* esto es malo? modificar directamente lo que esta en el Model? */
          g.getTableModel().setData(datos);
        }
        else
        {
          inventario.window.Mensaje.mensaje("Debe crear una grilla antes!");
        }
      },
      this);

      /* Agrega columna a la  Grilla */

      var but = this.getAddColButton();

      but.addListener("execute", function(e)
      {

        /* obtener dimension & datos actuales */

        var g = this.getGrid();

        if (g)
        {
          var datos = g.getTableModel().getData();
          var num_filas = datos.length;
          var num_columnas = (num_filas > 0) ? datos[0].length : 0;
          var nTabla = new Array();

          /* Copiar datos */

          for (var i=0; i<num_filas; i++)
          {
            var nRow = new Array();

            for (var j=0; j<num_columnas; j++) {
              nRow.push(datos[i][j]);
            }

            nRow.push("");  /* nueva columna */
            nTabla.push(nRow);
          }

          /* Crear nueva tabla */

          this._createGrid(num_filas, num_columnas + 1, []);
          this.getGrid().getTableModel().setData(nTabla);
        }
        else
        {
          inventario.window.Mensaje.mensaje("Debe crear una grilla antes!");
        }
      },
      this);

      /* Eliminar Columna */

      this.getEliminarColumnaButton().addListener("execute", function(e) {
        var numCol = this.setEliminarInput().getValue();
      },

      /* Copiar tabla sin columna y recrear tabla */

      this);

      /* Eliminar Fila */

      this.getEliminarFilaButton().addListener("execute", function(e) {
        var numFila = this.setEliminarInput().getValue();
      },

      /* Copiar tabla sin fila y recrear tabla */

      this);

      var but = this.getSaveGridButton();

      but.addListener("execute", function(e)
      {
        try
        {
          this._validateData();
          this._saveData();
        }
        catch(e)
        {
          inventario.window.Mensaje.mensaje("Error al intentar guardar la planilla: " + e);
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

      var but = this.getLoadGridButton();

      but.addListener("execute", function(e)
      {
        try
        {
          var cb = this.getListComboBox();
          var grid_id = inventario.widget.Form.getInputValueValidated(cb, "Planilla Invalida", "combobox", "");
          var opts = {};
          opts["url"] = this.getGetGridUrl();
          opts["parametros"] = null;
          opts["handle"] = this._loadGrid;
          opts["data"] = { grid_id : grid_id };
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
      var gb = new qx.ui.groupbox.GroupBox("Editor de Planillas");
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
        h.setDimension("100%", "5%");
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
             *  Parametros p/ una nueva planilla
             */

      try
      {
        var v = new qx.ui.layout.VerticalBoxLayout();
        v.setDimension("100%", "30%");
        v.setHorizontalChildrenAlign("center");
        this.setHboxA(v);

        var gl = inventario.widget.Grid.createGridLayout(3, 2,
        {
          width         : "50%",
          height        : "auto",
          colArrayWidth : [ "50%", "50%" ]
        });

        var l = new qx.ui.basic.Atom("Cantidad de Filas:");
        gl.add(l, 0, 0);
        gl.add(this.getRowInput(), 1, 0);

        var l = new qx.ui.basic.Atom("Cantidad de Columnas:");
        gl.add(l, 0, 1);
        gl.add(this.getColInput(), 1, 1);

        var l = new qx.ui.basic.Atom("Eliminar Fila o Columna:");
        gl.add(l, 0, 2);
        gl.add(this.getEliminarInput(), 1, 2);

        v.add(gl);

        /* Botones p/ crear y expandir la planilla */

        var grid_buttons_box = new qx.ui.layout.HorizontalBoxLayout();
        grid_buttons_box.setDimension("100%", "auto");
        grid_buttons_box.setHorizontalChildrenAlign("center");
        grid_buttons_box.add(this.getCreateGridButton());
        grid_buttons_box.add(this.getAddRowButton());
        grid_buttons_box.add(this.getAddColButton());
        grid_buttons_box.add(this.getEliminarColumnaButton());
        grid_buttons_box.add(this.getEliminarFilaButton());

        v.add(grid_buttons_box);

        vbox.add(v);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("Problemas al crear la primera parte " + e);
      }

      /*
             *  Planilla
             */

      try
      {
        var hbox = new qx.ui.layout.HorizontalBoxLayout();
        hbox.setDimension("100%", "55%");
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
        v.setDimension("100%", "10%");
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

        var l = new qx.ui.basic.Atom("Planillas Existentes:");
        gl.add(l, 0, 0);
        gl.add(this.getListComboBox(), 1, 0);
        gl.add(this.getLoadGridButton(), 2, 0);

        /*
                 *  Guardar planilla nueva o sobreescribir la que se edito
                 */

        var l = new qx.ui.basic.Atom("Nombre de Planilla:");
        gl.add(l, 0, 1);
        gl.add(this.getGridNameInput(), 1, 1);
        gl.add(this.getSaveGridButton(), 2, 1);

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
      opts["url"] = this.getListGridUrl();
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
      inventario.widget.Form.loadComboBox(cb, remoteData.planillas, true);

      this.prepared = true;
      this._doShow();
    },


    /**
     * validateData(): metodo abstracto
     *
     * @return {void} 
     * @throws TODOC
     */
    _validateData : function()
    {
      var g = this.getGrid();
      var datos = g.getTableModel().getData();
      this.saveG = inventario.parser.GridFormulaParser.toDbFormat(datos);  /* esto levanta una excepcion, llamar desde validateData() */

      var planillaNombre = this.getGridNameInput().getValue();

      if (planillaNombre && planillaNombre != "" && !planillaNombre.match(" ")) {
        this.planillaNombre = planillaNombre;
      } else {
        throw new Error("Debe proveer un nombre a la planilla");
      }
    },


    /**
     * saveData(): guardar Planilla, JSON-ificar,send
     *
     * @return {void} 
     */
    _saveData : function()
    {
      if (confirm("Guardar Planilla?"))
      {

        /* Json-ificar y enviar */

        var opts = {};
        opts["url"] = this.getSaveGridUrl();
        opts["parametros"] = null;
        opts["handle"] = this._saveDataResp;

        opts["data"] =
        {
          planilla : qx.util.Json.stringify(this.saveG),
          nombre   : this.planillaNombre
        };

        inventario.transport.Transport.callRemote(opts, this);
      }
    },

    /*
         * LEAK!: liberar this.saveG desde el callBack (this._saveDataResp)
         */

    /**
     * saveDataResp(): Se guardo OK?
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} 
     */
    _saveDataResp : function(remoteData, handleParams) {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);
    },


    /**
     * _loadGrid(): cargar una planilla para edicion
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} void
     */
    _loadGrid : function(remoteData, handleParams)
    {
      var g = remoteData["grid"];
      var row_num = g.length;
      var col_num = (row_num > 0) ? g[0].length : 0;
      this._createGrid(row_num, col_num, g);

      /*
             * Establecer el nombre de la planilla q esta siendo editada
             */

      var n = this.getListComboBox().getField().getValue();
      this.getGridNameInput().setValue(n);
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
      var h = new Array();
      var data;
      var width = 80;  /* medi con Kruler, parece razonable */
      var letra = 65;  /* A */

      for (var i=0; i<numCols; i++)
      {
        var t = String.fromCharCode(letra);

        h.push(
        {
          titulo   : t,
          editable : true,
          width    : width
        });

        letra++;
      }

      var g = inventario.widget.Table.createTable(h, "100%", "90%");

      if (grid && grid.length > 0)
      {

        /* Convertir a formato de formulas */

        data = inventario.parser.GridFormulaParser.toUserFormat(grid);
      }
      else
      {
        /*
                 * La grilla tiene que estar vacia inicialmente
                 */

        data = new Array();

        for (var i=0; i<numRows; i++)
        {
          var f = new Array();

          for (var j=0; j<numCols; j++) {
            f.push("");
          }

          data.push(f);
        }
      }

      g.getTableModel().setData(data);
      this.setGrid(g);

      this._removeGrid();

      /* guardar nuestra nueva grilla */

      this.getHboxB().add(g);
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