
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
// Abm2.js
// date: 2007-01-03
// author: Raul Gutierrez S.
//
// TODO: unify style of comments & indentation. 


/**
 * This class uses 4 methods:
 *
 * 1) searchUrl
 *    Execute a search, retrieving the results, plus (optionally) metadata
 *    about the columns.
 *
 * 2) addUrl: datos p/ formulario de nuevo element
 *
 * 3) saveUrl: guardar datos del formulario (en RoR seria crear un nuevo objeto)
 *
 * 4) deleteUrl: eliminar elemento
 */

/*
  #asset(qx/icon/Tango/16/actions/zoom-in.png)
  #asset(qx/icon/Tango/16/actions/go-previous.png)
  #asset(qx/icon/Tango/16/actions/go-next.png)
*/

qx.Class.define("inventario.window.Abm2",
{
  extend : inventario.window.AbstractWindow,

  construct : function(oMethods, title)
  {
    this.base(arguments);
    this.prepared = false;
    this._number_format = null;
    this._renderers_setup = false;

    try {
      this.setSearchUrl(oMethods.searchUrl);
      if (oMethods.addUrl) this.setAddUrl(oMethods.addUrl);
      if (oMethods.saveUrl) this.setSaveUrl(oMethods.saveUrl);
      if (oMethods.deleteUrl) this.setDeleteUrl(oMethods.deleteUrl);
    } catch(e) {
      alert(qx.locale.Manager.tr("Missing parameter in urls hash! ") + e.toString());
    }

    if (typeof (title) != "undefined") this.setTitle(title);

    this.setQueryComponents({});
  },

  destruct : function() {
    this._disposeObjects("_number_format");
  },

  properties :
  {
    paginated :
    {
      check : "Boolean",
      init  : false
    },

    refreshOnShow :
    {
      check : "Boolean",
      init  : true
    },

    title :
    {
      check : "String",
      init  : qx.locale.Manager.tr("Search")
    },

    selectionOptions :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    multiAbmFormConfigs :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    closeAfterChoose :
    {
      check : "Boolean",
      init  : true
    },

    window :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    maxRowPerPage :
    {
      check : "Number",
      init  : 500
    },

    defaultRowPerPage :
    {
      check : "Number",
      init  : 200
    },

    searchUrl :
    {
      check : "String",
      init  : ""
    },

    /* CRUD */
    addUrl : { check : "String" },
    saveUrl : { check : "String" },
    deleteUrl : { check : "String" },

    vista :
    {
      check : "String",
      init  : ""
      // BROKEN
      //apply : "_reloadVista"
    },

    searchConditions :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    queryComponents :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    resultsGrid :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    groupBox : { check : "Object" },
    verticalBox : { check : "Object" },
    mainVerticalBox : { check : "Object" },
    searchAreaBox : { check : "Object" },
    gridAreaBox : { check : "Object" },
    bottomAreaBox : { check : "Object" },
    navAreaBox : { check : "Object" },
    crudAreaBox : { check : "Object" },

    searchAdvancedButton : { check : "Object" },
    searchAdvancedData : { check : "Object" },
    searchAdvanced : { check : "Object" },
    searchTextField : { check : "Object" },
    searchOptions : { check : "Object" },

    searchButtonText :
    {
      check : "String",
      init  : qx.locale.Manager.tr("Search")
    },

    searchButton : { check : "Object" },
    prevButton : { check : "Object" },
    nextButton : { check : "Object" },
    firstButton : { check : "Object" },
    lastButton : { check : "Object" },
    deleteButton : { check : "Object" },
    modifyButton : { check : "Object" },
    addButton : { check : "Object" },
    detailsButton : { check : "Object" },

    filasSpinner : { check : "Object" },

    withChooseButton :
    {
      check : "Boolean",
      init  : false
    },

    chooseButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    chooseButtonText :
    {
      check : "String",
      init  : qx.locale.Manager.tr("Choose")
    },

    chooseButtonIcon :
    {
      check : "String",
      init  : "check"
    },

    chooseButtonCallBack :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    chooseButtonCallBackContext :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    chooseButtonCallBackInputField :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    chooseButtonCallBackParams :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    chooseComboBox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    chooseComboBoxId :
    {
      check : "Number",
      init  : -1
    },

    chooseComboBoxDesc :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    showAddButton :
    {
      check : "Boolean",
      init  : true
    },

    showDeleteButton :
    {
      check : "Boolean",
      init  : true
    },

    showModifyButton :
    {
      check : "Boolean",
      init  : true
    },

    showDetailsButton :
    {
      check : "Boolean",
      init  : true
    },

    /* Guardar el box donde tengo que colocar el laberl referente al numero de pagina que se esta viendo */
    boxCurrentPage :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /* Guardo el numero de registros encontrados */
    results :
    {
      check : "Number",
      init  : 0
    },

    showExcelExportButton :
    {
      check : "Boolean",
      init  : true
    },

    fechaActual :
    {
      check : "String",
      init  : ""
    },

    title :
    {
      check : "String",
      init  : qx.locale.Manager.tr("Listing")
    }
  },


  members :
  {
    launch : function()
    {
      if (this.prepared) {
        this.open();

        if (this.getRefreshOnShow()) {
          this._navegar();
        }
      } else {

        this._createInputs();
        this._setHandlers();
        this._createLayout();
        this._loadInitialData();
    
        var scope_id = inventario.window.Abm2SetScope.getInstance().getScope();
        if (scope_id > 0) {
	  /* If there is some scope, set it and get out of the function
	   * because the setVista function checker it's going to 
	   * load the initial data.
	   */
	  this.setVista("scope_" + scope_id);
	  return; 
        }
      }
    },

    checkRefresh : function(huboCambios)
    {
      if (huboCambios) {
        this._navegar();
      }
    },

    _createInputs : function()
    {
      /*
                   * Elementos del Buscador
                   */

      var tf = new qx.ui.form.TextField();
      this.setSearchTextField(tf);

      var cb = new qx.ui.form.SelectBox();
      this.setSearchOptions(cb);

      var t = this.getSearchButtonText();
      var but = new qx.ui.form.Button(t, "qx/icon/Tango/16/actions/zoom-in.png");
      this.setSearchButton(but);

      var but = new qx.ui.form.Button("", "qx/icon/Tango/16/actions/zoom-in.png");
      this.setSearchAdvancedButton(but);

      // var s = new qx.ui.form.Spinner(1, this.getDefaultRowPerPage(), this.getMaxRowPerPage());
      var s = new qx.ui.form.Spinner();

      s.set(
      {
        maximum   : 500,
        value : 200,
        minimum   : 1
      });

      var nf = new qx.util.format.NumberFormat();
      nf.setMaximumFractionDigits(0);
      s.setNumberFormat(nf);
      this._number_format = nf;
      this.setFilasSpinner(s);

      /*
                   * Botones de Navegacion
                   */

      var bFirst = new qx.ui.form.Button(qx.locale.Manager.tr("First Page "), "qx/icon/Tango/16/actions/go-previous.png");

      /* Se deshabilita el boton << porque al comienzo estamos en la primera pagina */

      bFirst.setEnabled(false);
      this.setFirstButton(bFirst);

      var bPrev = new qx.ui.form.Button(qx.locale.Manager.tr("Previous"), "qx/icon/Tango/16/actions/go-previous.png");

      /* Se deshabilita el boton < porque al comienzo estamos en la primera pagina */

      bPrev.setEnabled(false);
      this.setPrevButton(bPrev);

      var bNext = new qx.ui.form.Button(qx.locale.Manager.tr("Next"), "qx/icon/Tango/16/actions/go-next.png");

      /* Se deshabilita el boton >, despues e habilitara si el numero de paginas encontrados > 1 */

      bNext.setEnabled(false);
      this.setNextButton(bNext);

      var bLast = new qx.ui.form.Button(qx.locale.Manager.tr("Last Page"), "qx/icon/Tango/16/actions/go-next.png");

      /* Se deshabilita el boton >>, despues e habilitara si el numero de paginas encontrados > 1 */

      bLast.setEnabled(false);
      this.setLastButton(bLast);

      if (this.getShowExcelExportButton())
      {
        var f = function() {
          this._exportExcel();
        };

        var h =
        {
          type            : "button",
          icon            : "excel",
          text            : qx.locale.Manager.tr("Export"),
          callBackFunc    : f,
          callBackContext : this
        };

        this.getToolBarButtons().push(h);
        this.getToolBarButtons().push({ type : "separator" });
      }

      /*
                   * Botones de ABM
                   */

      if (this.getShowAddButton())
      {
        var f = function() {
          this._addRow(false, false);
        };

        var h =
        {
          type            : "button",
          icon            : "add",
          text            : qx.locale.Manager.tr("Add"),
          tooltip         : "Ctrl+A",
          accel_keyboard  : "Control+A",
          callBackFunc    : f,
          callBackContext : this
        };

        this.getToolBarButtons().push(h);
        this.getToolBarButtons().push({ type : "separator" });
      }

      if (this.getShowModifyButton())
      {
        var h =
        {
          type            : "button",
          icon            : "edit_pen",
          text            : qx.locale.Manager.tr("Edit"),
          tooltip         : "Ctrl+M",
          accel_keyboard  : "Control+M",
          callBackFunc    : this._modify,
          callBackContext : this
        };

        this.getToolBarButtons().push(h);
        this.getToolBarButtons().push({ type : "separator" });
      }

      if (this.getShowDetailsButton())
      {
        var h =
        {
          type            : "button",
          icon            : "dictionary",
          text            : qx.locale.Manager.tr("Details"),
          tooltip         : "Ctrl+D",
          accel_keyboard  : "Control+D",
          callBackFunc    : this._details,
          callBackContext : this
        };

        this.getToolBarButtons().push(h);
        this.getToolBarButtons().push({ type : "separator" });
      }

      if (this.getWithChooseButton())
      {
        var t = this.getChooseButtonText();

        var f = this._elegirFila;

        var h =
        {
          type            : "button",
          icon            : this.getChooseButtonIcon(),
          text            : t,
          callBackFunc    : f,
          tooltip         : qx.locale.Manager.tr("Enter"),
          callBackContext : this
        };

        this.getToolBarButtons().push(h);
        this.getToolBarButtons().push({ type : "separator" });
      }

      if (this.getShowDeleteButton())
      {

        /* botones de comandos */

        var h =
        {
          type            : "button",
          icon            : "delete2",
          text            : qx.locale.Manager.tr("Remove"),
          tooltip         : "Ctrl+E",
          accel_keyboard  : "Control+E",
          callBackFunc    : this._deleteRows,
          callBackContext : this
        };

        this.getToolBarButtons().push(h);
        this.getToolBarButtons().push({ type : "separator" });
      }

      var f = function(e) {
        this.close();
      };

      var h =
      {
        type            : "button",
        icon            : "exit",
        text            : qx.locale.Manager.tr("Close"),
        callBackFunc    : f,
        callBackContext : this
      };

      this.getToolBarButtons().push(h);
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
      this.getSearchTextField().addListener("keydown", function(e)
      {
        if (e.getKeyIdentifier() == 'Enter')
        {
          this.getSearchTextField().blur();
          this.getSearchButton().execute();
        }
      },
      this);

      var b = this.getSearchButton();

      b.addListener("execute", function(e)
      {
        try
        {
          /* New search; return to first page */
          this._page = 1;
          this._validateData();
          this._doSearch();
        }
        catch(e)
        {
          inventario.window.Mensaje.mensaje(e.toString());
        }
      },
      this);

      var b = this.getSearchAdvancedButton();

      b.addListener("execute", function(e) {
        this._advancedSearch();
      }, this);

      this.getPrevButton().addListener("execute", this._navegarPaginaAnterior, this);
      this.getNextButton().addListener("execute", this._navegarPaginaSiguiente, this);
      this.getFirstButton().addListener("execute", this._navegarPrimeraPagina, this);
      this.getLastButton().addListener("execute", this._navegarUltimaPagina, this);

      /* Abreviacion para boton de pagina anterior */
      this._addAccelerator("Control+Left", this._navegarPaginaAnterior, this);

      /* Abreviacion para boton de pagina siguiente */
      this._addAccelerator("Control+Right", this._navegarPaginaSiguiente, this);

      /* Abreviacion para boton de primera pagina */
      this._addAccelerator("Control+Up", this._navegarPrimeraPagina, this);

      /* Abreviacion para boton de ultima pagina */
      this._addAccelerator("Control+Down", this._navegarUltimaPagina, this);

      /* Abreviacion para el combobox de criterio de busqueda */
      this._addAccelerator("Control+T", this._searchOptionsFocus, this);

      /* Abreviacion para el textfield de cadena de busqueda */
      this._addAccelerator("Control+N", this._searchTextFieldFocus, this);

      /* Abreviacion para el boton de busqueda avanzada */
      this._addAccelerator("Control+S", this._advancedSearch, this);
    },

    _searchTextFieldFocus : function() {
      this.getSearchTextField().focus();
    },

    _searchOptionsFocus : function() {
      this.getSearchOptions().focus();
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
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20), { height : 700 });
      this.setVerticalBox(vbox);

      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox());
      hbox.setPadding(6);
      this.setSearchAreaBox(hbox);

      var gl = new qx.ui.layout.Grid();
      var container = new qx.ui.container.Composite(gl);

      var label = new qx.ui.basic.Label(qx.locale.Manager.tr("Search Criteria: "));

      container.add(label,
      {
        row    : 0,
        column : 0
      });

      container.add(this.getSearchOptions(),
      {
        row    : 0,
        column : 1
      });

      var label = new qx.ui.basic.Label(qx.locale.Manager.tr("Search string: "));

      container.add(label,
      {
        row    : 0,
        column : 2
      });

      container.add(this.getSearchTextField(),
      {
        row    : 0,
        column : 3
      });

      container.add(this.getSearchButton(),
      {
        row    : 0,
        column : 4
      });

      container.add(this.getSearchAdvancedButton(),
      {
        row    : 0,
        column : 5
      });

      container.add(new qx.ui.basic.Label(qx.locale.Manager.tr("Per page.:")),
      {
        row    : 0,
        column : 6
      });

      container.add(this.getFilasSpinner(),
      {
        row    : 0,
        column : 7
      });

      hbox.add(container);
      vbox.add(hbox, { flex : 1 });

      // we delay adding the table with the data since columns come from the server
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox());
      this.setGridAreaBox(hbox);
      vbox.add(hbox, { flex : 5 });

      // lower area: navigation commands
      var inferiorBox = new qx.ui.container.Composite(new qx.ui.layout.VBox());

      var navhbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(5));
      this.setNavAreaBox(navhbox);
      navhbox.add(this.getFirstButton());
      navhbox.add(this.getPrevButton());
      navhbox.add(this.getNextButton());
      navhbox.add(this.getLastButton());
      inferiorBox.add(navhbox);

      // label to display number of results
      var labelBox = new qx.ui.container.Composite(new qx.ui.layout.HBox(30));
      this._page_label = new qx.ui.basic.Label();
      this._num_results_label = new qx.ui.basic.Label();
      labelBox.add(this._page_label);
      labelBox.add(this._num_results_label);
      inferiorBox.add(labelBox);

      vbox.add(inferiorBox, { flex : 1 });
    },

    updateTable : function() {
      this._navegar();
    },


    /**
     * loadInitialData():
     * 
     *  - Pedir opciones de busqueda y columnas de tabla
     *  - tambien le damos comienzo a algunas variables de control
     *  - traemos el listado inicial
     *
     * @return {void} 
     */
    _loadInitialData : function()
    {
      this._page = 1;  // current page
      this._numPages = 0;  // cantidad de paginas en el listado
      this._sort_column = null;
      this._sort = "asc";
      this._internal_sort = false; // sort is happening, not triggered by user
    
      var dhash = this.getDataHashQuery();
      dhash["need_column_info"] = true;

      inventario.transport.Transport.callRemote(
      {
        url        : this.getSearchUrl(),
        parametros : null,
        handle     : this._loadInitialDataResp,
        data       : dhash
      },
      this);
    },


    /**
     * _loadInitialDataResp():
     * 
     *  Que esperamos del servidor:
     *  - criterios (formato de loadcombo() )
     *  - col_titles (vector de titulos de la tabla de resultados)
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadInitialDataResp : function(remoteData, params)
    {
      if (remoteData["fecha"])
        this.setFechaActual(remoteData["fecha"]);

      var columns = remoteData["columns"];

      /* Search field combo box */
      var cb = this.getSearchOptions();
      var combo_data = [];
      for (var i=0; i < columns.length; i++) {
        if ("searchable" in columns[i] && !columns[i].searchable)
          continue;

        if (!("db_column" in columns[i]))
          continue;

        var col = {
          text: columns[i].name,
          value: columns[i].db_column
        }
        if (columns[i].default_search)
          col.selected = true;
        combo_data.push(col);
      }
      inventario.widget.Form.loadComboBox(cb, combo_data, true);

      this.setSearchAdvancedData(remoteData["columns"]);

      /* Table */
      var h = [];
      for (var i=0; i < columns.length; i++) {
        var width = (columns[i].width ? columns[i].width : 100);
        var tmp = {
          titulo   : columns[i].name,
          editable : true,
          width    : width
        };
        if ("visible" in columns[i])
          tmp.visible = columns[i].visible;
        if ("sortable" in columns[i])
          tmp.sortable = columns[i].sortable;
        h.push(tmp);
      }
      var table = inventario.widget.Table.createTable(h, 400, 300);
      table.setMinHeight(300);

      table.getTableModel().addListener("sorted", function(e)
        {
          var data = e.getData();
          this._sort = data.ascending ? "asc" : "desc";
          this._sort_column = data.columnIndex;

          if (!this._internal_sort)
            this._doSearch();
        },
        this);
 
      table.getSelectionModel().setSelectionMode(qx.ui.table.selection.Model.MULTIPLE_INTERVAL_SELECTION);
      this.getGridAreaBox().add(table, { flex : 1 });
      this.setResultsGrid(table);

      // listen to 'Enter' to select a row
      // FIXME: is this working?
      if (this.getWithChooseButton())
      {
        table.addListener("keydown", function(e)
        {
          if (e.getKeyIdentifier() == 'Enter') {
            this._elegirFila();
          }
        },
        this);
      }

      this._showResults(remoteData);

      /* Datos para saber que columnas utilizar para cargar un combobox */
      if (remoteData["elegir_data"]) {
        var col_desc = remoteData["elegir_data"]["desc_col"];
        var col_id = remoteData["elegir_data"]["id_col"];
        this.setChooseComboBoxDesc(col_desc);
        this.setChooseComboBoxId(col_id);

        /* Condiciones para filas seleccionables */
        if (remoteData["elegir_data"]["selection_options"])
          this.setSelectionOptions(remoteData["elegir_data"]["selection_options"]);
      }

      var mainVBox = this.getVbox();
      mainVBox.add(this._buildCommandToolBar(true));
      mainVBox.add(this.getVerticalBox());

      /*
                   * Cuando se carga el Abm lo normal es querer buscar...
                   */

      this.getSearchTextField().addListener("appear", function() {
        this.getSearchTextField().focus();
      }, this);

      this.setCaption(this.getTitle());

    /* {@crodas} Little hook to setScope, to update to the new scope on ASAP  {{{ */
        var scope = inventario.window.Abm2SetScope.getInstance();
        scope.addListener("changeScope", function(q) { 
            this.setVista("scope_" + q.getData());
        }, this);
    /* }}} */

      this.prepared = true;
      this.open();
    },

    /**
     * validateData(): metodo abstracto
     * 
     * TODO: Levantar una excepcion aca si hay algun problema de validacion
     *
     * @return {void} 
     */
    _validateData : function()
    {
      // Tch says: New Advanced Search system
      var value = this.getSearchTextField().getValue();

      var cb = this.getSearchOptions();
      var key = inventario.widget.Form.getInputValue(cb);

      if (value == null || value == "") {
          this.setQueryComponents({});
      } else {
        var components = {};

        components[key] =
        {
          operators : [ " regexp ? " ],
          values    : [ value ]
        };

        this.setQueryComponents(components);
      }
    },

    /**
     * saveData(): enviar busqueda al servidor
     *
     * @param newSearch {var} Es una nueva busqueda?
     *       Enviamos al servidor:
     *       - query (cadena de busqueda)
     *       - query_option (criterio de busqueda)
     * @return {void} 
     */
    _doSearch : function()
    {
      inventario.transport.Transport.callRemote(
      {
        url        : this.getSearchUrl(),
        parametros : null,
        handle     : this._searchResp,
        data       : this.getDataHashQuery()
      },
      this);
    },

    /**
     * saveDataResp(): Carga Resultados de la Busqueda
     * 
     * Esperamos del servidor:
     * - rows (filas de la tabla)
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} 
     */
    _searchResp : function(remoteData, handleParams)
    {
      this._showResults(remoteData);

      // Select first row
      if (remoteData["rows"] && remoteData["rows"].length > 0) {
        this.getResultsGrid().getSelectionModel().setSelectionInterval(0, 0);
      }
    },

    /**
     * _addRow(): agregar un nuevo elemento
     *
     * @param editRow {var} si es >=0 es un id de un objeto que se va editar
     * @param details {var} TODOC
     * @return {void} void
     *     
     *       FIXME : no deberia ser privada!
     */
    _addRow : function(editRow, details)
    {
      var dataUrl = this.getAddUrl();
      var saveUrl = this.getSaveUrl();
      var add_form = new inventario.window.AbmForm(dataUrl, saveUrl);

      if (typeof (editRow) == "object")
      {
        // batch editing
        if (editRow.length > 1)
        {
          add_form.setEditIds(editRow);
          add_form.setEditRow(0);
        }
        else
        {
          add_form.setEditRow(parseInt(editRow[0]));
        }
      }
      else
      {
        var editVal = (!editRow ? 0 : editRow);
        add_form.setEditRow(parseInt(editVal));
      }

      add_form.setDetails(details);
      add_form.setSaveCallback(this._addRowHandler);
      add_form.setSaveCallbackObj(this);
      add_form.setVista(this.getVista());
      add_form.launch();
    },

    _addRowHandler : function(filaAgregada, remoteData)
    {
      if (remoteData["id"])
      {
        // aca suponemos que siempre el primer items de select es el id
        this.queryOption = remoteData["primary_key"];
      }

      this._navegar();
    },

    _setupRenderers : function(rows)
    {
      /* Only setup renderers the first time we receive row data. */
      if (this._renderers_setup || rows.length == 0)
        return;

      var table = this.getResultsGrid();
      var len = rows[0].length;
      var tcm = table.getTableColumnModel();

      for (var i=0; i < len; i++) {
        if (typeof (rows[0][i]) == "object") {
          tcm.setDataCellRenderer(i, new inventario.qooxdoo.ListDataCellRenderer());
        } else if (typeof (rows[0][i]) == "boolean") {
          tcm.setDataCellRenderer(i, new qx.ui.table.cellrenderer.Boolean());
          table.removeListener("cellClick", this._seleccionarCheckBox, this);
          table.addListener("cellClick", this._seleccionarCheckBox, this);
        }
      }

      this._renderers_setup = true;
    },

    /**
     * _cargarFilas():  cargar datos en la grilla
     *
     * @param filas {Array} vector de filas
     * @return {void} void
     */
    _cargarFilas : function(remoteData)
    {
    },

    _deleteRows : function()
    {
      var table = this.getResultsGrid();
      var ids = table.getSelected2([ 0 ], true);

      if (ids.length > 0 && confirm(qx.locale.Manager.tr("Delete selected items")))
      {
        var payload = qx.lang.Json.stringify(ids);
        var data = { payload : payload };
        var vista = this.getVista();

        if (vista != "")
          data["vista"] = vista;

        inventario.transport.Transport.callRemote(
        {
          url        : this.getDeleteUrl(),
          parametros : null,
          handle     : this._deleteRowsResp,
          data       : data
        },
        this);
      }
    },

    _deleteRowsResp : function(remoteData, handleParams)
    {
      var msg = (remoteData["msg"] ? remoteData["msg"] : qx.locale.Manager.tr(" Deleted row "));
      inventario.window.Mensaje.mensaje(msg);
      this._navegar();
    },

    /**
     * _navegar():  desplazarse a traves del result set
     *
     * @return {void} void
     */
    _navegar : function()
    {
      if (!this.queryOption || (this.queryOption && this.queryOption == "")) {
        var cb = this.getSearchOptions();
        this.queryOption = inventario.widget.Form.getInputValue(cb);
      }

      this._doSearch();
    },

    _modify : function()
    {
      var table = this.getResultsGrid();
      var ids = table.getSelected2([ 0 ], true);

      if (ids.length > 0) {
        this._addRow(ids, false);
      } else {
        inventario.window.Mensaje.mensaje(qx.locale.Manager.tr("You must select a row"));
      }
    },

    _details : function()
    {
      var table = this.getResultsGrid();
      var ids = table.getSelected2([ 0 ], false);

      if (ids.length > 0) {
        this._addRow(ids[0], true);
      } else {
        inventario.window.Mensaje.mensaje(qx.locale.Manager.tr("You must select a row"));
      }
    },

    _updatePageWidgets : function()
    {
      var str = this.tr("Displaying results page %1 of %2");
      str = qx.lang.String.format(str, [this._page, this._numPages]);
      this._page_label.setValue(str);

      str = this.tr("Number of results found: %1");
      str = qx.lang.String.format(str, [this.getResults()]);
      this._num_results_label.setValue(str);

      this.getFirstButton().setEnabled(this._page != 1);
      this.getPrevButton().setEnabled(this._page != 1);
      this.getNextButton().setEnabled(this._page < this._numPages);
      this.getLastButton().setEnabled(this._page != this._numPages);
    },

    getDataHashQuery : function()
    {
      var datos = this.getQueryComponents();

      var per_page = this.getFilasSpinner().getValue();
      per_page = ((per_page && per_page > 0) ? per_page : 100);

      var dhash =
      {
        payload   : qx.lang.Json.stringify(datos),
        page      : this._page,
        per_page  : per_page
      };

      if (this._sort_column != null) {
        dhash.sort_column = this._sort_column
        dhash.sort = this._sort;
      }

      var vista = this.getVista();
      if (vista != "")
        dhash["vista"] = vista;

      return dhash;
    },

    _showResults : function(remoteData)
    {
      var table = this.getResultsGrid();
      var model = table.getTableModel();

      this._setupRenderers(remoteData["rows"]);

      /* Display data */
      model.setData(remoteData["rows"]);

      /* Indicate how the data is sorted */
      if ("sort_column" in remoteData) {
        this._internal_sort = true;
        model.sortByColumn(remoteData.sort_column, remoteData.sort != "desc");
        this._internal_sort = false;
      }

      /* Update page numbers etc */
      this._numPages = remoteData["page_count"];
      this.setResults(remoteData["results"]);
      this._page = remoteData["page"];
      this._updatePageWidgets();
    },

    _navegarPaginaAnterior : function(e)
    {
      if (this._page > 1) {
        this._page--;
        this._navegar();
      }
    },

    _navegarPaginaSiguiente : function(e)
    {
      if (this._numPages > this._page) {
        this._page++;
        this._navegar();
      }
    },

    _navegarPrimeraPagina : function(e)
    {
      if (this._page != 1) {
        this._page = 1;
        this._navegar();
      }
    },

    _navegarUltimaPagina : function(e)
    {
      if (this._numPages > 1) {
        this._page = this._numPages;
        this._navegar();
      }
    },

    _advancedSearch : function()
    {
      try
      {
        var f = function(components)
        {
          this.setQueryComponents(components);
          this._doSearch();
        };

        var datos =
        {
          objeto  : this,
          funcion : f
        };

        if (this.getFechaActual() != "") {
          datos["fecha"] = this.getFechaActual();
        }

        this.setSearchAdvanced(new inventario.widget.SearchAdvanced(this.getSearchAdvancedData(), datos));
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("Abm2.setHandlers SearchAdvanced: " + e);
      }
    },

    _elegirFila : function(e)
    {
      var filasSeleccionadas = this.getResultsGrid().getSelected2(null, true);

      if (filasSeleccionadas.length > 0) {
	this._doSelectRow(filasSeleccionadas);
      } else {
	var error_str = qx.locale.Manager.tr("You must select at least one row.");
        inventario.window.Mensaje.mensaje(error_str);
      }
    },

    /**
     * TODOC
     *
     * @param filasSeleccionadas {Array} selected rows
     * @return {void} 
     *
     * FIXME: the try/catch in the the branch of the IF seems unnecessary. 
     *
     */
   _doSelectRow : function(filasSeleccionadas) { 
      var cb = this.getChooseComboBox();

      if (cb) {

	try {
	  var col_desc = this.getChooseComboBoxDesc();
	  var col_id = this.getChooseComboBoxId();

	  if (parseInt(col_id) >= 0) {
	    var agregarFila = true;
	    var agregarFilaMsgError = "";

	    if (this.getSelectionOptions()) {
	      var agregarFilaCol = this.getSelectionOptions()["col_id"];
	      agregarFilaMsgError = this.getSelectionOptions()["msg_error"];
	      agregarFilaCol = parseInt(agregarFilaCol);
	      var agregarFilaValorHabilita = this.getSelectionOptions()["expected_value"];
	      
	      if (filasSeleccionadas[0][agregarFilaCol] != agregarFilaValorHabilita) {
		var agregarFila = false;
	      }
	    }

	    if (agregarFila) {
                var tmp = new Array();
                var len = col_desc.columnas.length;

                for (var i=0; i<len; i++) {
		  var tmpStr = filasSeleccionadas[0][col_desc.columnas[i]];

		  if (tmpStr && !tmpStr.match(/^ *$/)) {
		    tmp.push(tmpStr);
		  }
		}

                // We save the row in the CB (in case the user needs more info) 
                cb.setUserData("filaSeleccionada", filasSeleccionadas[0]);

                var text = tmp.join(col_desc.separator);
                var val = filasSeleccionadas[0][col_id];
                var v = [ { text : text, value : val, selected : true } ];
                inventario.widget.Form.loadComboBox(cb, v, true);

                if (this.getCloseAfterChoose())
                  this.close();
	    } else { 
	      inventario.window.Mensaje.mensaje(agregarFilaMsgError);
	    }
	  } else {
	    var error_str = qx.locale.Manager.tr("Contact the System Administrator: Configuration Error");
	    inventario.window.Mensaje.mensaje(error_str);
	  }
	} catch(e) {
	  var error_str = qx.locale.Manager.tr("Abm2: problem inserting selected row in ComboBox:\n");
	  inventario.window.Mensaje.mensaje(error_str + e);
	}

      } else {

	var f = this.getChooseButtonCallBack();

	if (this.getChooseButtonCallBackInputField()) {
	  this.getChooseButtonCallBackInputField().setUserData("filasSeleccionadas", filasSeleccionadas);
	}

	f.call(this.getChooseButtonCallBackContext(), filasSeleccionadas, 
	       this.getChooseButtonCallBackInputField(), this.getChooseButtonCallBackParams());

	if (this.getCloseAfterChoose())
	  this.close();

      }
    }, 

    _seleccionarCheckBox : function(e)
    {
      var col = e.getColumn();
      var row = e.getRow();
      var table = this.getResultsGrid();
      var tableModel = table.getTableModel();

      var datos = inventario.widget.Table.copiarTabla(table);

      if (typeof (datos[row][col]) == "boolean")
      {
        datos[row][col] = !datos[row][col];
        tableModel.setData(datos);
      }
    },

    _exportExcel : function()
    {
      var tm = this.getResultsGrid().getTableModel();
      var titulos;
      var datos;

      if (confirm(qx.locale.Manager.tr("Export only visible columns?")))
      {
        datos = this.getResultsGrid().getVisibleData();
        titulos = this.getResultsGrid().getVisibleColumnNames();
      }
      else
      {
        datos = tm.getData();
        titulos = new Array();
        var nro_columnas = datos[0].length;

        for (var i=0; i<nro_columnas; i++) {
          titulos.push(tm.getColumnName(i));
        }
      }

      var hopts = {};
      hopts["datos"] = qx.lang.Json.stringify(datos);
      hopts["titulos"] = qx.lang.Json.stringify(titulos);
      inventario.util.PrintManager.printExcel("planilla", hopts);
    },


    _reloadVista:  function () {
        this.setQueryComponents({});
        this._doSearch();
    },

    _addCustomButton : function(btn) {
      var f = function() {
        var form = new inventario.window.AbmForm(btn.addUrl, btn.saveUrl);
        if (btn.refresh_abm)
          form.addListener("disappear", function(e) {
              this._navegar();
            }, this);
        form.launch();
      };

      var h =
      {
        type            : "button",
        icon            : btn.icon,
        text            : btn.text,
        callBackFunc    : f,
        callBackContext : this
      };

      this.getToolBarButtons().push(h);
    },

    addCustomButtons : function(buttons) {
      for (var i in buttons)
        this._addCustomButton(buttons[i]);
    }
  }
});
