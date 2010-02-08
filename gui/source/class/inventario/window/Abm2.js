
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
// fecha: 2007-01-03
// autor: Raul Gutierrez S.
//
//
// Un Abm que soporta busqueda & listado completo
//
//
/**
 * Esta clase utiliza 6 metodos:
 *
 * 1) searchUrl: un metodo al cual se le envian 2 parametros:
 *               a) query (cadena de busqueda)
 *               b) query_option (criterio de busqueda)
 *    y retorna:
 *        - rows: la matriz de resultados para cargar en la grilla via table.getTableModel().setData(rows);
 *
 * 2) initialDataUrl: no se le envian parametros (de momento) y devuelve:
 *                    - criterios (formato de loadcombo() )
 *                    - col_titles (vector de titulos de la tabla de resultados)
 *                    - rows  (filas iniciales)
 *                    - page_count (cantidad de paginas)
 *                    - elegir_data (hash) {id_col, desc_col}
 *
 * 3) listUrl: listado
 *
 * 4) addUrl: datos p/ formulario de nuevo element
 *
 * 5) saveUrl: guardar datos del formulario (en RoR seria crear un nuevo objeto)
 *
 * 6) deleteUrl: eliminar elemento
 *
 *
 * @param page {}  Puede ser null
 * @param oMethods {Hash}  hash de configuracion {searchUrl,initialDataUrl,...}
 * @return void
 */
qx.Class.define("inventario.window.Abm2",
{
  extend : inventario.window.AbstractWindow,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function(page, oMethods, title)
  {
    this.base(arguments, page);
    this.prepared = false;

    this._searchMode = false;

    /* Cargar parametros sinhe quae non */

    try
    {
      this.setSearchUrl(oMethods.searchUrl);
      this.setInitialDataUrl(oMethods.initialDataUrl);

      this.setListUrl(oMethods.listUrl);
      if (oMethods.addUrl) this.setAddUrl(oMethods.addUrl);
      if (oMethods.saveUrl) this.setSaveUrl(oMethods.saveUrl);
      if (oMethods.deleteUrl) this.setDeleteUrl(oMethods.deleteUrl);
    }
    catch(e)
    {
      alert("Falta un parametro en el hash de urls! " + e.toString());
    }

    if (typeof (title) != "undefined") this.setTitle(title);

    /*
             * Iniciar algunas ayudadores
             */

    this.setExtraButtons(new Array());

    // Tch says: new advanced search system
    this.setQueryComponents({});

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

    refreshOnShow :
    {
      check : "Boolean",
      init  : true
    },

    title :
    {
      check : "String",
      init  : "Buscador"
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

    /* KU 2007-04-04 */

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

    /* Para guardar la referencia a los popus que abre ABM2 */

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

    /*
             *  RPC
             */

    /* busqueda */

    searchUrl :
    {
      check : "String",
      init  : ""
    },

    initialDataUrl :
    {
      check : "String",
      init  : ""
    },

    /* CRUD */

    listUrl : { check : "String" },
    addUrl : { check : "String" },
    saveUrl : { check : "String" },
    deleteUrl : { check : "String" },

    /*
             * params: Vista y filtros de busqueda
             */

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

    /*
             * Widgets & Containers
             */

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

    /*
             * Inputs & Buttons
             */

    searchAdvancedButton : { check : "Object" },
    searchAdvancedData : { check : "Object" },
    searchAdvanced : { check : "Object" },
    searchTextField : { check : "Object" },
    searchOptions : { check : "Object" },

    searchButtonText :
    {
      check : "String",
      init  : "Buscar"
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

    // KU: voy a incluir spinner para la cantida de fila
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
      init  : "Elegir"
    },

    chooseButtonIcon :
    {
      check : "String",
      init  : "check"
    },

    /* si usamos un callback (probablemente quieran insertar a una tabla lo seleccionado.. */

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

    /* si directamente se quiere insertar a un combobox */

    chooseComboBox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /* Las columnas de las cuales quitar el value y el text p/ insertar al ComboBox */

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

    /* KU 2007-03-26 nuevo, properties
             *  DEPREACTED: usar getExtraButtons()
             */

    withArrayButton :
    {
      check : "Boolean",
      init  : false
    },

    arrayButtonLen :
    {
      check    : "Number",
      init     : null,
      nullable : true
    },

    arrayButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    arrayButtonUsesSelected :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    arrayButtonText :
    {
      check : "Object",
      init  : "Agregar"
    },

    arrayButtonIcon :
    {
      check : "Object",
      init  : "icon/16/actions/zoom-in.png"
    },

    arrayButtonCallBack :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    arrayButtonCallBackContext :
    {
      check    : "Object",
      init     : null,
      nullable : true
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

    /* Vector de hashes con configuraciones de botones */

    extraButtons :
    {
      check    : "Object",
      init     : null,
      nullable : true
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
      init  : "Listado"
    },

    abmFormCloseAfterInsert :
    {
      check : "Boolean",
      init  : true
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
      if (this.prepared)
      {

        /* Habria que cerar widgets antes de empezar */

        this._doShow();

        if (this.getRefreshOnShow()) {
          this._navegar();
        }
      }
      else
      {

        /* traer datos y preparar widgets */

        this._createInputs();
        this._setHandlers();
        this._createLayout();
        this._loadInitialData();
        /* {@crodas} {{{ */
        /* Load default scope ID */
        scope_id = inventario.window.Abm2SetScope.getInstance().getScope();
        if (scope_id > 0) {
            /* If there is some scope, set it and get out of the function
             * because the setVista function checker it's going to 
             * load the initial data.
             */
            this.setVista("scope_" + scope_id);
            return; 
        }
        /* }}} */
      }
    },


    /**
     * checkRefresh()
     *
     * @param huboCambios {var} TODOC
     * @return {void} void
     */
    checkRefresh : function(huboCambios)
    {
      if (huboCambios) {
        this._navegar();
      }
    },


    /**
     * _doShow()
     *
     * @return {void} void
     */
    _doShow : function()
    {
      var mainVBox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));
      mainVBox.add(this._buildCommandToolBar(true));
      mainVBox.add(this.getVerticalBox());

      this._doShow2(mainVBox);

      /*
                   * Cuando se carga el Abm lo normal es querer buscar...
                   */

      this.getSearchTextField().addListener("appear", function() {
        this.getSearchTextField().focus();
      }, this);

      this.setWindowTitle(this.getTitle());

    /* {@crodas} Little hook to setScope, to update to the new scope on ASAP  {{{ */
        var scope = inventario.window.Abm2SetScope.getInstance();
        scope.addListener("changeScope", function(q) { 
            this.setVista("scope_" + q.getData());
        }, this);
    /* }}} */

    },


    /**
     * createInputs():
     *
     * @return {void} 
     */
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
      var but = new qx.ui.form.Button(t, "icon/16/actions/zoom.png");
      this.setSearchButton(but);

      var but = new qx.ui.form.Button("", "icon/16/actions/zoom-in.png");
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
      this.setFilasSpinner(s);

      /*
                   * Botones de Navegacion
                   */

      var bFirst = new qx.ui.form.Button("Primera Pagina", "icon/16/actions/go-previous.png");

      /* Se deshabilita el boton << porque al comienzo estamos en la primera pagina */

      bFirst.setEnabled(false);
      this.setFirstButton(bFirst);

      var bPrev = new qx.ui.form.Button("Anterior", "icon/16/actions/go-previous.png");

      /* Se deshabilita el boton < porque al comienzo estamos en la primera pagina */

      bPrev.setEnabled(false);
      this.setPrevButton(bPrev);

      var bNext = new qx.ui.form.Button("Siguiente", "icon/16/actions/go-next.png");

      /* Se deshabilita el boton >, despues e habilitara si el numero de paginas encontrados > 1 */

      bNext.setEnabled(false);
      this.setNextButton(bNext);

      var bLast = new qx.ui.form.Button("Ultima Pagina", "icon/16/actions/go-next.png");

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
          text            : "Exportar",
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
          text            : "Agregar",
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
          text            : "Modificar",
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
          text            : "Detalles",
          tooltip         : "Ctrl+D",
          accel_keyboard  : "Control+D",
          callBackFunc    : this._details,
          callBackContext : this
        };

        this.getToolBarButtons().push(h);
        this.getToolBarButtons().push({ type : "separator" });
      }

      /* KU 2007-03-26 nuevo, properties
                   *   DEPRECATED: usar getExtraButtons()
                   */

      if (this.getWithArrayButton())
      {
        try
        {
          var len = this.getArrayButtonLen();

          for (var i=0; i<len; i++)
          {
            var t = this.getArrayButtonText()[i];
            var icon = "aisa/image/22/" + this.getArrayButtonIcon()[i] + ".png";
            var boton = new qx.ui.toolbar.Button(t, icon);
            boton.setUserData("i", i);
            boton.setUserData("self", this);

            boton.addListener("execute", function(e)
            {
              var i = this.getUserData("i");
              var self = this.getUserData("self");
              var context = self;
              var f = self.getArrayButtonCallBack()[i];
              var filasSeleccionadas = inventario.widget.Table.getSelected2(self.getResultsGrid(), null, true);

              /* Por default todo el mundo necesita que una fila este seleccionada p/ que se llame al callback de su boton */

              var len_seleccion = (self.getArrayButtonUsesSelected() ? self.getArrayButtonUsesSelected().length : 0);
              var necesita_seleccion = (len_seleccion == 0 || self.getArrayButtonUsesSelected()[i]);

              if (necesita_seleccion && filasSeleccionadas.length == 0) {
                inventario.window.Mensaje.mensaje("Debe seleccionar una fila al menos.");
              }
              else
              {
                if (self.getArrayButtonCallBackContext()) context = self.getArrayButtonCallBackContext()[i];
                f.call(context, filasSeleccionadas);
              }
            },
            boton);

            var h =
            {
              type            : "toolBarButton",
              object          : boton,
              callBackContext : this
            };

            this.getToolBarButtons().push(h);
            this.getToolBarButtons().push({ type : "separator" });
          }
        }
        catch(e)
        {
          inventario.window.Mensaje.mensaje("Abm2 withArrayButton :" + e.toString());
        }
      }

      /*
                   *  Botones varios
                   */

      if (this.getExtraButtons().length > 0)
      {
        var len = this.getExtraButtons().length;

        for (var i=0; i<len; i++)
        {
          var button_config = this.getExtraButtons()[i];
          var h = {};
          h["text"] = button_config["button_text"];
          h["icon"] = button_config["button_icon"];
          h["callBackContext"] = this;
          var priv_data = {};
          priv_data["uses_selected"] = button_config["uses_selected"];
          priv_data["callback"] = button_config["callback"];
          priv_data["callback_ctxt"] = button_config["callback_context"];
          h["priv_data"] = priv_data;

          var f = function(e)
          {
            var but = e.getTarget();
            var f = but.getUserData("callback");
            var filasSeleccionadas = inventario.widget.Table.getSelected2(this.getResultsGrid(), null, true);

            var necesita_seleccion = but.getUserData("uses_selected");

            if (necesita_seleccion && filasSeleccionadas.length == 0) {
              inventario.window.Mensaje.mensaje("Debe seleccionar una fila al menos.");
            }
            else
            {
              var context = (but.getUserData("callback_context") ? but.getUserData("callback_context") : this);
              f.call(context, filasSeleccionadas);
            }
          };

          h["callBackFunc"] = f;
          h["type"] = "button";
          h["accel_keyboard"] = button_config["accel_keyboard"];

          this.getToolBarButtons().push(h);
          this.getToolBarButtons().push({ type : "separator" });
        }
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
          tooltip         : "Enter",
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
          text            : "Eliminar",
          tooltip         : "Ctrl+E",
          accel_keyboard  : "Control+E",
          callBackFunc    : this._deleteRows,
          callBackContext : this
        };

        this.getToolBarButtons().push(h);
        this.getToolBarButtons().push({ type : "separator" });
      }

      /* Si estoy en un popup agrego a la barra el boton cerrar */

      if (this.getUsePopup())
      {

        /* boton de salir */

        var f = function(e) {
          this.getAbstractPopupWindow().getWindow().close();
        };

        var h =
        {
          type            : "button",
          icon            : "exit",
          text            : "Cerrar",
          callBackFunc    : f,
          callBackContext : this
        };

        this.getToolBarButtons().push(h);

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
      /*
                   * Asociar el enter al boton de busqueda a la pagina y al textfield
                   */

      this.getSearchTextField().addListener("keydown", function(e)
      {
        if (e.getKeyIdentifier() == 'Enter')
        {
          this.getSearchTextField().blur();
          this.getSearchButton().execute();
        }
      },
      this);

      /*
                   * Elementos del Buscador
                   */

      var b = this.getSearchButton();

      b.addListener("execute", function(e)
      {
        try
        {
          this._validateData();
          this._saveData(true);
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

      /*
                   * Botones de Navegacion
                   */

      this.getPrevButton().addListener("execute", this._navegarPaginaAnterior, this);
      this.getNextButton().addListener("execute", this._navegarPaginaSiguiente, this);
      this.getFirstButton().addListener("execute", this._navegarPrimeraPagina, this);
      this.getLastButton().addListener("execute", this._navegarUltimaPagina, this);

      /*
                   * Abreviaciones de Teclado
                   */

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


    /**
     * TODOC
     *
     * @return {void} 
     */
    _searchTextFieldFocus : function() {
      this.getSearchTextField().focus();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _searchOptionsFocus : function() {
      this.getSearchOptions().focus();
    },

    /*
             * Botones de ABM
             */

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

      var label = new qx.ui.basic.Label("Criterio de Busqueda: ");

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

      var label = new qx.ui.basic.Label("Cadena de Busqueda: ");

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

      container.add(new qx.ui.basic.Label("Por pag.:"),
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

      /* la tabla de resultados se demora ya que las columnas vienen del servidor */

      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox());
      this.setGridAreaBox(hbox);
      vbox.add(hbox, { flex : 5 });

      /*
                   * Area inferior: navegacion y ABM buttons
                   */

      var inferiorBox = new qx.ui.container.Composite(new qx.ui.layout.VBox());

      var navhbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(5));
      this.setNavAreaBox(navhbox);
      navhbox.add(this.getFirstButton());
      navhbox.add(this.getPrevButton());
      navhbox.add(this.getNextButton());
      navhbox.add(this.getLastButton());
      inferiorBox.add(navhbox);

      /* Etiqueta de cantidad de resultados */

      var labelBox = new qx.ui.container.Composite(new qx.ui.layout.HBox(30));
      this.setBoxCurrentPage(labelBox);
      inferiorBox.add(labelBox);

      vbox.add(inferiorBox, { flex : 1 });
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
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
      this._pages = 1;  // pagina actual
      this._numPages = 0;  // cantidad de paginas en el listado
    
      var url = this.getInitialDataUrl();
      var dhash = this.getDataHashQuery();

      inventario.transport.Transport.callRemote(
      {
        url        : url,
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
      if (remoteData["fecha"]) {
        this.setFechaActual(remoteData["fecha"]);
      }

      /*
                   * Opciones de busqueda
                   */

      var cb = this.getSearchOptions();
      inventario.widget.Form.loadComboBox(cb, remoteData["criterios"], true);
      this.setSearchAdvancedData(remoteData["criterios"]);

      /*
                   * Crear tabla
                   */

      var listColumns = remoteData["cols_titles"];  // titulos para el listado
      var h = new Array();
      var len = listColumns.length;

      for (var i=0; i<len; i++)
      {
        var width = (remoteData["criterios"][i]["width"] ? remoteData["criterios"][i]["width"] : 100);

        h.push(
        {
          titulo   : remoteData["cols_titles"][i],
          editable : true,
          width    : width
        });
      }

      var table = inventario.widget.Table.createTable(h, 400, 300);
      table.setMinHeight(300);

      if (remoteData["columnas_visibles"])
      {
        var len = remoteData["columnas_visibles"].length;

        for (var i=0; i<len; i++)
        {
          var visibleBool = remoteData["columnas_visibles"][i];

          if (!visibleBool) {
            table.getTableColumnModel().setColumnVisible(i, visibleBool);
          }
        }
      }

      table.getSelectionModel().setSelectionMode(qx.ui.table.selection.Model.MULTIPLE_INTERVAL_SELECTION);
      this.getGridAreaBox().add(table, { flex : 1 });
      this.setResultsGrid(table);

      /*
                   * Capturamos el Enter para eligir una fila
                   */

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

      /*
                   * Cargar datos
                   */

      this._actualizarPantalla(remoteData);

      /* Datos para saber que columnas utilizar para cargar un combobox */

      if (remoteData["elegir_data"])
      {
        var col_desc = remoteData["elegir_data"]["desc_col"];
        var col_id = remoteData["elegir_data"]["id_col"];
        this.setChooseComboBoxDesc(col_desc);
        this.setChooseComboBoxId(col_id);

        /* Condiciones para filas seleccionables */

        if (remoteData["elegir_data"]["selection_options"]) {
          this.setSelectionOptions(remoteData["elegir_data"]["selection_options"]);
        }
      }

      /* activamos los botones > y >> si es que la cantida de paginas encontradas es > 1 */

      if (this._numPages > 1)
      {
        this.getNextButton().setEnabled(true);
        this.getLastButton().setEnabled(true);
      }

      /* estamos listos p/ mostrarnos */

      this.prepared = true;

      this._doShow();
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

      // this.queryStr = this.getSearchTextField().getValue();
      var cb = this.getSearchOptions();
      var key = inventario.widget.Form.getInputValue(cb);

      // this.queryOption = inventario.widget.Form.getInputValue(cb);
      if (value == "") {
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
    _saveData : function(newSearch)
    {
      var url = this.getSearchUrl();
      var dhash = this.getDataHashQuery();

      inventario.transport.Transport.callRemote(
      {
        url        : url,
        parametros : newSearch,
        handle     : this._saveDataResp,
        data       : dhash
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
    _saveDataResp : function(remoteData, handleParams)
    {
      if (remoteData["rows"].length > 0)
      {
        this._searchMode = true;
        this._numPages = remoteData["page_count"];

        if (handleParams) {
          this._pages = 1;
        }
      }

      this._actualizarPantalla(remoteData);

      /* Seleccionar primera */

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
      var add_form = new inventario.window.AbmForm(null, {});

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
        add_form.setEditRow(editVal);
      }

      add_form.setDetails(details);
      add_form.setSaveCallback(this._addRowHandler);
      add_form.setSaveCallbackObj(this);
      var url = this.getAddUrl();
      add_form.setInitialDataUrl(url);
      var url = this.getSaveUrl();
      add_form.setSaveUrl(url);
      add_form.setVista(this.getVista());
      add_form.setCloseAfterInsert(this.getAbmFormCloseAfterInsert());
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
      var msg = (remoteData["msg"] ? remoteData["msg"] : " Fila agregada ");
      inventario.window.Mensaje.mensaje(msg);

      if (remoteData["id"])
      {
        // no se para que sirve esta variable, dsp se tendria que sacar
        this._searchMode = true;
        this.queryStr = remoteData["id"];

        // aca suponemos que siempre el primer items de select es el id
        this.queryOption = remoteData["primary_key"];
      }

      this._navegar();
    },


    /**
     * _cargarFilas():  cargar datos en la grilla
     *
     * @param filas {Array} vector de filas
     * @return {void} void
     */
    _cargarFilas : function(filas)
    {
      var table = this.getResultsGrid();

      /*
                   * FIXME: Esto habria que hacer una unica vez..
                   */

      if (filas.length > 0)
      {
        var len = filas[0].length;
        var tcm = table.getTableColumnModel();

        for (var i=0; i<len; i++)
        {
          if (typeof (filas[0][i]) == "object") {
            tcm.setDataCellRenderer(i, new inventario.qooxdoo.ListDataCellRenderer());
          }
          else if (typeof (filas[0][i]) == "boolean")
          {
            tcm.setDataCellRenderer(i, new qx.ui.table.cellrenderer.Boolean());

            // tcm.setCellEditorFactory(i, new qx.ui.table.celleditor.CheckBox());
            /*
                        		 * Handler p/ activar CheckBox
                        		 */

            table.removeListener("cellClick", this._seleccionarCheckBox, this);
            table.addListener("cellClick", this._seleccionarCheckBox, this);
          }
        }
      }

      table.getTableModel().setData(filas);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _deleteRows : function()
    {
      var table = this.getResultsGrid();
      var ids = inventario.widget.Table.getSelected2(table, [ 0 ], true);

      if (ids.length > 0 && confirm("Eliminar elementos seleccionados"))
      {
        var payload = qx.util.Json.stringify(ids);
        var data = { payload : payload };
        var vista = this.getVista();

        if (vista != "") {
          data["vista"] = vista;
        }

        var url = this.getDeleteUrl();

        inventario.transport.Transport.callRemote(
        {
          url        : url,
          parametros : null,
          handle     : this._deleteRowsResp,
          data       : data
        },
        this);
      }
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} 
     */
    _deleteRowsResp : function(remoteData, handleParams)
    {
      var msg = (remoteData["msg"] ? remoteData["msg"] : " Fila borrada ");
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
      if (!this._searchMode) {
        this.queryStr = "";
      }

      if (!this.queryOption || (this.queryOption && this.queryOption == ""))
      {
        var cb = this.getSearchOptions();
        this.queryOption = inventario.widget.Form.getInputValue(cb);
      }

      this._saveData(false);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _modify : function()
    {
      var table = this.getResultsGrid();
      var ids = inventario.widget.Table.getSelected2(table, [ 0 ], true);

      if (ids.length > 0) {
        this._addRow(ids, false);
      } else {
        inventario.window.Mensaje.mensaje("Debe seleccionar una fila");
      }
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _details : function()
    {
      var table = this.getResultsGrid();
      var ids = inventario.widget.Table.getSelected2(table, [ 0 ], false);

      if (ids.length > 0) {
        this._addRow(ids[0], true);
      } else {
        inventario.window.Mensaje.mensaje("Debe seleccionar una fila");
      }
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _showPageNumber : function()
    {
      var cadena = "Visualizando pagina de resultados: " + this._pages + " de " + this._numPages;
      var cadena2 = "Cantidad de resultados encontrados: " + this.getResults();
      this.getBoxCurrentPage().removeAll();
      this.getBoxCurrentPage().add(new qx.ui.basic.Label(cadena2));
      this.getBoxCurrentPage().add(new qx.ui.basic.Label(cadena));
    },

    /*
             *  Prepara los parametros p/ search_controller
             */

    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    getDataHashQuery : function()
    {
      // Tch says: Deprecated
      /* var conds = this.getSearchConditions();
            
                  if (conds) {
            
            	      var vQuery = conds["values"].concat();
            	      var vColumns = conds["columns"].concat();
            
            	      if (this.queryStr && this.queryOption) {
            	        if (typeof (this.queryStr) == "object") {
            
            		        vQuery.concat(this.queryStr);
            		        vColumns.concat(this.queryOption);
            	        } else {
            
            		        vQuery.push(this.queryStr);
            		        vColumns.push(this.queryOption);
            	        }
            	      }
            
            	      var datos = {
            
            	        query        : vQuery,
            	        query_option : vColumns
            	      };
                } else {
            
            	      var datos = {
            
            	        query        : this.queryStr,
            	        query_option : this.queryOption
            	      };
            	  } */

      var datos = this.getQueryComponents();

      var cant_fila = this.getFilasSpinner().getValue();
      cant_fila = ((cant_fila && cant_fila > 0) ? cant_fila : 100);

      var dhash =
      {
        payload   : qx.util.Json.stringify(datos),
        page      : this._pages,
        cant_fila : cant_fila
      };

      var vista = this.getVista();

      if (vista != "") {
        dhash["vista"] = vista;
      }

      return dhash;
    },

    /* _actualizarPantalla()
             * - Carga las filas
             * - Actualiza contadores (de paginas,filas)
             * - Actualiza labels de resultados
             */

    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @return {void} 
     */
    _actualizarPantalla : function(remoteData)
    {
      this._cargarFilas(remoteData["rows"]);
      this._numPages = remoteData["page_count"];
      this.setResults(remoteData["results"]);
      this._showPageNumber();
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _navegarPaginaAnterior : function(e)
    {
      if (this._pages == this._numPages)
      {

        /* Habilitar los botones >> y > porque acabo de pasar de la primera pagina */

        this.getLastButton().setEnabled(true);
        this.getNextButton().setEnabled(true);
      }

      if (this._pages > 1)
      {
        this._pages--;
        this._navegar();
        this._showPageNumber();
      }

      if (this._pages == 1)
      {

        /* Deshabilitar los botones << y < porque llegue a la primera pagina */

        this.getPrevButton().setEnabled(false);
        this.getFirstButton().setEnabled(false);
      }
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _navegarPaginaSiguiente : function(e)
    {
      if (this._pages == 1)
      {

        /* Habilitar los botones << y < porque acabo de pasar de la primera pagina */

        this.getPrevButton().setEnabled(true);
        this.getFirstButton().setEnabled(true);
      }

      if (this._numPages > this._pages)
      {
        this._pages++;
        this._navegar();
        this._showPageNumber();
      }

      if (this._pages == this._numPages)
      {

        /* Deshabilitar los botones de > y >> porque llegue a la ultima pagina */

        this.getLastButton().setEnabled(false);
        this.getNextButton().setEnabled(false);
      }
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _navegarPrimeraPagina : function(e)
    {
      if (this._pages != 1)
      {

        /* Deshabilitar los botones de << y < porque estoy en la primera pagina */

        this.getPrevButton().setEnabled(false);
        this.getFirstButton().setEnabled(false);

        /* Habilitar los botones de >> y > */

        this.getNextButton().setEnabled(true);
        this.getLastButton().setEnabled(true);

        this._pages = 1;
        this._navegar();
        this._showPageNumber();
      }
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _navegarUltimaPagina : function(e)
    {
      if (this._numPages > 1)
      {

        /* Deshabilitar los botones de >> y > porque estoy en la ultima pagina */

        this.getNextButton().setEnabled(false);
        this.getLastButton().setEnabled(false);

        /* Habilitar los botones de << y < */

        this.getPrevButton().setEnabled(true);
        this.getFirstButton().setEnabled(true);

        this._pages = this._numPages;
        this._navegar();
        this._showPageNumber();
      }
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _advancedSearch : function()
    {
      try
      {
        // Tch says: Deprecated
        /* var f = function(str, option)
                          {
                            this.queryStr = str;
                            this.queryOption = option;
                            this._saveData(true);
                          }; */

        var f = function(components)
        {
          this.setQueryComponents(components);
          this._saveData(true);
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


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _elegirFila : function(e)
    {
      var filasSeleccionadas = inventario.widget.Table.getSelected2(this.getResultsGrid(), null, true);

      if (filasSeleccionadas.length > 0)
      {
        var cb = this.getChooseComboBox();

        if (cb)
        {
          try
          {

            /* Cargar a un combobox los datos de la primera fila seleccionada */

            var col_desc = this.getChooseComboBoxDesc();
            var col_id = this.getChooseComboBoxId();

            if (parseInt(col_id) >= 0)
            {  /* me cubro la espalda contra lo que aun no se implemento en el servidor */
              var agregarFila = true;
              var agregarFilaMsgError = "";

              if (this.getSelectionOptions())
              {
                /*
                                		   * La idea es asegurar que una Columna tenga cierto valor seteado
                                		   */

                var agregarFilaCol = this.getSelectionOptions()["col_id"];
                agregarFilaMsgError = this.getSelectionOptions()["msg_error"];
                agregarFilaCol = parseInt(agregarFilaCol);
                var agregarFilaValorHabilita = this.getSelectionOptions()["expected_value"];

                if (filasSeleccionadas[0][agregarFilaCol] != agregarFilaValorHabilita) {
                  var agregarFila = false;
                }
              }

              if (agregarFila)
              {
                var tmp = new Array();
                var len = col_desc.columnas.length;

                for (var i=0; i<len; i++)
                {
                  var tmpStr = filasSeleccionadas[0][col_desc.columnas[i]];

                  if (tmpStr && !tmpStr.match(/^ *$/)) {
                    tmp.push(tmpStr);
                  }
                }

                var text = tmp.join(col_desc.separator);
                var val = filasSeleccionadas[0][col_id];

                var v = [
                {
                  text     : text,
                  value    : val,
                  selected : true
                } ];

                /*  Ademas le guardamos en el combobox la fila..
                                		     *  Entonces si el usuario necesita algun dato de mas puede obtenerlo dp ;)
                                		     */

                cb.setUserData("filaSeleccionada", filasSeleccionadas[0]);

                inventario.widget.Form.loadComboBox(cb, v, true);

                if (this.getCloseAfterChoose()) {
                  this.getAbstractPopupWindow().getWindow().close();
                }
              }
              else
              {
                inventario.window.Mensaje.mensaje(agregarFilaMsgError);
              }
            }
            else
            {
              inventario.window.Mensaje.mensaje("Contacte con el Administrador del Sistema :: Error de Configuracion");
            }
          }
          catch(e)
          {
            inventario.window.Mensaje.mensaje("Abm2, CreateInput en Choose Button\n" + e);
          }
        }
        else
        {

          /* Vamos a llamar al callBack... */

          var f = this.getChooseButtonCallBack();

          /* tambien le pasamos todas las filas  seleccionadas via el input asociado */

          if (this.getChooseButtonCallBackInputField()) {
            this.getChooseButtonCallBackInputField().setUserData("filasSeleccionadas", filasSeleccionadas);
          }

          f.call(this.getChooseButtonCallBackContext(), filasSeleccionadas, this.getChooseButtonCallBackInputField(), this.getChooseButtonCallBackParams());

          if (this.getCloseAfterChoose()) {
            this.getAbstractPopupWindow().getWindow().close();
          }
        }
      }
      else
      {
        inventario.window.Mensaje.mensaje("Debe seleccionar una fila al menos.");
      }
    },

    /* _seleccionarCheckBox():
             *   actualizar el estado de un checkbox
             */

    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
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

    /*
             * De momento quitamos todo lo que hay.. seria interesante tener una configuracion en algun lado donde
             * se diga si se exportan todas las filas o solamente las seleccionadas
             */

    /**
     * TODOC
     *
     * @return {void} 
     */
    _exportExcel : function()
    {
      var tm = this.getResultsGrid().getTableModel();
      var titulos;
      var datos;

      if (confirm("Exportar solo columnas visibles?"))
      {
        datos = inventario.widget.Table.getVisibleData(this.getResultsGrid());
        titulos = inventario.widget.Table.getVisibleColumnNames(this.getResultsGrid());
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
      hopts["datos"] = qx.util.Json.stringify(datos);
      hopts["titulos"] = qx.util.Json.stringify(titulos);
      inventario.util.PrintManager.printExcel("planilla", hopts);
    },


    _reloadVista:  function () {
        this._pages = 1;  // pagina actual
        this._numPages = 0;  // cantidad de paginas en el listado
        this.setQueryComponents({});
        this._saveData(true);
    }
  }
});
