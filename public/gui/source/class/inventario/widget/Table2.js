
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
// Table2.js
// fecha: 2007-19-01
// autor: Raul Gutierrez S.
//
//
//
qx.Class.define("inventario.widget.Table2",
{
  extend : qx.ui.container.Composite,

  construct : function()
  {
    this.base(arguments, new qx.ui.layout.VBox(20));
    this.prepared = false;
    this.setHashKeys(new Array());
  },

  statics :
  {
    isEmpty2 : function(mat, row, useEmpty)
    {
      var ret = false;

      if (useEmpty)
      {
        if (typeof (mat[row][0]) == "object")
        {
          if (mat[row][0].text == " " && mat[row][0].value == "-1") {
            ret = true;
          }
        }
        else
        {
          if (mat[row][0] == " ") {
            ret = true;
          }
        }
      }

      return ret;
    }
  },

  properties :
  {
    /* parametros de comportamiento */

    useEmptyTable :
    {
      check : "Boolean",
      init  : false
    },

    /* botones */

    buttonsAlignment :
    {
      check : "String",
      init  : "left"
    },

    withButtons :
    {
      check : "Boolean",
      init  : true
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

    showSelectButton :
    {
      check : "Boolean",
      init  : true
    },

    showModifyButton :
    {
      check : "Boolean",
      init  : true
    },

    addButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    deleteButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    selectButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    modifyButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    addButtonLabel :
    {
      check : "String",
      init  : qx.locale.Manager.tr("Add")
    },

    addButtonIcon :
    {
      check : "String",
      init  : "icon/16/actions/zoom-in.png"
    },

    addButtonTooltipLabel :
    {
      check : "String",
      init  : qx.locale.Manager.tr("Add row")
    },

    deleteButtonLabel :
    {
      check : "String",
      init  : qx.locale.Manager.tr("Remove")
    },

    deleteButtonIcon :
    {
      check : "String",
      init  : "icon/16/actions/dialog-cancel.png"
    },

    deleteButtonTooltipLabel :
    {
      check : "String",
      init  : qx.locale.Manager.tr("Remove row")
    },

    /* contenedor & grilla */

    titles :
    {
      check : "Object",
      init  : null
    },

    editables :
    {
      check : "Object",
      init  : null
    },

    widths :
    {
      check : "Object",
      init  : null
    },

    grid :
    {
      check : "Object",
      init  : null
    },

    gridData :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    colsNum :
    {
      check : "Number",
      init  : 5
    },

    rowsNum :
    {
      check : "Number",
      init  : 15
    },

    tableHeight :
    {
      check : "Number",
      init  : 0
    },

    tableWidth :
    {
      check : "Number",
      init  : 0
    },

    /* procesamiento de cambios - formulas y totalizadores */

    formulaTable :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /* Objeto asociado. En su contexto se procesan las formulas */

    formulaContext :
    {
      check : "Object",
      init  : null
    },

    /* vector de funciones suscriptas a cambios en la tabla */

    gridHandlers :
    {
      check : "Object",
      init  : null
    },

    /* como retirar la info. de la tabla y "Hash-ear" */

    hashKeys :
    {
      check : "Object",
      init  : null
    },

    columnasVisibles :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    usarTotalizador :
    {
      check : "Boolean",
      init  : false
    },

    totalizadorLabel :
    {
      check : "String",
      init  : "Total :"
    },

    totalizador :
    {
      check : "Number",
      init  : 0
    },

    totalizadorInput :
    {
      check : "Object",
      init  : null
    }
  },

  members :
  {
    /**
     * launch(): rock & roll!
     * 
     * Volar de aca estos try/catch cuando este todo depurado
     *
     * @return {void} 
     */
    launch : function()
    {
      if (!this.prepared)
      {
        this._createInputs();
        this._setHandlers();
        this._createLayout();
      }

      try
      {
        var data = this.getGridData();
        var activate_handlers = true;

        if (this.getUseEmptyTable())
        {
          var rows_num;

          if (!data)
          {  /* tabla vacia entonces! */
            data = new Array();
            rows_num = this.getRowsNum();
          }
          else
          {

            /* Completamos con la cantidad de filas en blanco necesarias */

            rows_num = (data.length < this.getRowsNum() ? (this.getRowsNum() - data.length) : 0);
          }

          this._addEmptyRows(data, rows_num, this.getColsNum());
          this.setGridData(data);
          activate_handlers = false;
        }

        /* this._doSetData(activate_handlers,data); */

        this.getGrid().getTableModel().setData(data);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("Tabl2.launch() setData() =>" + e);
      }

      this._setRenderers(this.getGridData()[0]);  /* renderers */
      this.prepared = true;
    },

    _createInputs : function()
    {
      var tableModel = new qx.ui.table.model.Simple();
      tableModel.setColumns(this.getTitles());

      var editables = this.getEditables();

      if (editables)
      {
        for (var i=0; i<editables.length; i++) {
          tableModel.setColumnEditable(i, editables[i]);
        }
      }

      var custom =
      {
        tableColumnModel : function(obj) {
          return new qx.ui.table.columnmodel.Resize(obj);
        }
      };

      var table = new qx.ui.table.Table(tableModel, custom);

      var height = this.getTableHeight();
      var width = this.getTableWidth();

      if (height > 0) {
        table.setHeight(height);
      }

      if (width > 0) {
        table.setWidth(width);
      }

      table.setStatusBarVisible(false);
      table.getSelectionModel().setSelectionMode(qx.ui.table.selection.Model.MULTIPLE_INTERVAL_SELECTION);

      // Obtain the behavior object to manipulate
      var anchos = this.getWidths();

      if (anchos) {
	var resizeBehavior = table.getTableColumnModel().getBehavior();

	for (var i=0; i<anchos.length; i++) {
	  resizeBehavior.set(i, { width : anchos[i] });
	}
      }

      if (this.getColumnasVisibles()) {
        var len = this.getColumnasVisibles().length;

        for (var i=0; i<len; i++)
        {
          var visibleBool = this.getColumnasVisibles()[i];
          table.getTableColumnModel().setColumnVisible(i, visibleBool);
        }
      }

      this.setGrid(table);

      /* Botones */

      if (this.getWithButtons())
      {
        if (this.getShowAddButton())
        {
          var label = this.getAddButtonLabel();
          var icon = this.getAddButtonIcon();
          var tooltip_label = this.getAddButtonTooltipLabel();
          var but;

          if (icon != "") {
            but = new qx.ui.form.Button(label, icon);
          } else {
            but = new qx.ui.form.Button(label);
          }

          this.setAddButton(but);
        }

        if (this.getShowDeleteButton())
        {
          var label = this.getDeleteButtonLabel();
          var icon = this.getDeleteButtonIcon();
          var tooltip_label = this.getDeleteButtonTooltipLabel();
          var but;

          if (icon != "") {
            but = new qx.ui.form.Button(label, icon);
          } else {
            but = new qx.ui.form.Button(label);
          }

          this.setDeleteButton(but);
        }

        if (this.getShowSelectButton())
        {
          var but = new qx.ui.form.Button(qx.locale.Manager.tr("Select All"), "icon/16/actions/view-pane-text.png");
          this.setSelectButton(but);
        }

        if (this.getShowModifyButton())
        {
          var but = new qx.ui.form.Button(qx.locale.Manager.tr("Edit"), "icon/16/apps/accessories-text-editor.png");
          this.setModifyButton(but);
        }
      }

      if (this.getUsarTotalizador() && this.getTotalizadorInput() == null)
      {
        var i = new qx.ui.form.TextField();
        i.setReadOnly(true);
        i.setValue("0");
        i.setTextAlign("right");

        this.setTotalizadorInput(i);
      }
    },


    /**
     * _setHandlers():
     * 
     *  Los handlers de modificacion & nueva fila tienen que ser definidos por el usuario
     * 
     *  TODO: esto se presta a ser extendido y que las clases que heredan definan metodos add & modify
     *
     * @return {void} 
     */
    _setHandlers : function()
    {
      if (this.getWithButtons())
      {

        /* eliminar filas */

        if (this.getShowDeleteButton()) {
          this.getDeleteButton().addListener("execute", this.deleteRow, this);
        }

        /* seleccionar todo */

        if (this.getShowSelectButton()) {
          this.getSelectButton().addListener("execute", this.selectRow, this);
        }
      }

      var v = new Array();
      this.setGridHandlers(v);
      this.getGrid().getTableModel().addListener("dataChanged", this._dataChangedHandler, this);
    },

    /**
     * _setRenderers(): establecer renderers de las columnas
     *
     * @param row {Array} una fila  para ver que tipo de datos tiene
     * @return {void} void
     */
    _setRenderers : function(row)
    {
      var len = row.length;
      var tcm = this.getGrid().getTableColumnModel();

      for (var i=0; i<len; i++)
      {
        var tipo = typeof (row[i]);

        if (tipo == "object") {
          tcm.setDataCellRenderer(i, new inventario.qooxdoo.ListDataCellRenderer());
        }
        else if (tipo == "boolean")
        {
          tcm.setDataCellRenderer(i, new qx.ui.table.cellrenderer.Boolean());
          tcm.setCellEditorFactory(i, new qx.ui.table.celleditor.CheckBox());
        }
        else
        {
          tcm.setDataCellRenderer(i, new qx.ui.table.cellrenderer.Default());
        }
      }
    },

    /**
     * _createLayout(): metodo abstracto
     * 
     * Posicionamiento de inputs
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var tableBox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));

      tableBox.add(this.getGrid());
      this.add(tableBox);

      if (this.getWithButtons())
      {
        var buttonsContenedorHbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));

        var buttonsHbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
        var align = this.getButtonsAlignment();

        if (this.getShowAddButton()) {
          buttonsHbox.add(this.getAddButton());
        }

        if (this.getShowDeleteButton()) {
          buttonsHbox.add(this.getDeleteButton());
        }

        if (this.getShowSelectButton()) {
          buttonsHbox.add(this.getSelectButton());
        }

        if (this.getShowModifyButton()) {
          buttonsHbox.add(this.getModifyButton());
        }

        buttonsContenedorHbox.add(buttonsHbox);

        if (this.getUsarTotalizador())
        {
          var totalizadorHbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
          var align = this.getButtonsAlignment();
          var totalLabel = this.getTotalizadorLabel();
          totalizadorHbox.add(new qx.ui.basic.Atom(totalLabel));
          totalizadorHbox.add(this.getTotalizadorInput());
          buttonsContenedorHbox.add(totalizadorHbox);
        }

        this.add(buttonsContenedorHbox);
      }
    },

    _loadInitialData : function() {
      throw new Error("loadInitialData is abstract");
    },

    _validateData : function() {
      throw new Error("validateData is abstract");
    },

    _saveData : function() {
      throw new Error("saveData is abstract");
    },


    /**
     * _dataChangedHandler(): desde aca disparamos a todas las funciones suscriptas a cambios en la tabla
     *
     * @param e {Event} TODOC
     * @return {void} void
     */
    _dataChangedHandler : function(e)
    {
      var tm = this.getGrid().getTableModel();

      tm.removeListener("dataChanged", this._dataChangedHandler, this);  // empieza la contencion.. ignoramos eventos

      var funciones = this.getGridHandlers();
      var len = funciones.length;

      for (var i=0; i<len; i++) {
        funciones[i].call(this);
      }

      tm.addListener("dataChanged", this._dataChangedHandler, this);  // fin de contencion
    },


    /**
     * addRows():
     *
     * @param filas {Array} matriz de filas
     * @param col {Number} numero de columna para ver si existe
     * @param selected {Boolean} para saber si se esta modificando
     * @return {void} void
     */
    addRows : function(filas, col, selected)
    {

      /* no rows to add... nothing to do. */

      if (!filas || (filas && filas.length == 0)) {
        return;
      }

      var tabla = this.getGrid();
      var ban = false;
      if (col == -1) ban = true;

      try
      {

        /* es un buen momento para establecer los renderers.. por si no hubo data al iniciar */

        this._setRenderers(filas[0]);

        if (!this.getUseEmptyTable()) {
          for (var i=0; i<col.length; i++) tabla.addRow(col[i], filas);
        }
        else
        {

          /* tenes que buscar la primera fila vacia (con string " ") y agregar ahi */

          var data = tabla.getTableModel().getData();
          var lenf = data.length;
          var lenc = (lenf > 0) ? data[0].length : 0;
          var data2 = new Array();
          var col_repetido = (!ban && (parseInt(col) && parseInt(col) >= 0) ? parseInt(col) : 0);
          var sm = tabla.getSelectionModel();

          for (var i=0; i<lenf; i++)
          {
            if (this.isEmpty(data, i)) {
              break;
            }

            var seleccionado = (selected && sm.isSelectedIndex(i));

            if (seleccionado)
            {
              var fila = new Array();

              for (var j=0; j<lenc; j++) {
                fila.push(filas[0][j]);
              }

              data2.push(fila);
            }
            else if (ban || !this.isRowRepeated(data[i], filas, col_repetido))
            {
              var fila = new Array();

              for (var j=0; j<lenc; j++) {
                fila.push(data[i][j]);
              }

              data2.push(fila);
            }
          }

          var numDataRows = i;

          /* agregar nuevas filas */

          lenf = filas.length;

          if (!selected)
          {
            for (var i=0; i<lenf; i++)
            {
              var fila = new Array();

              /*
                                     * TODO: verificar si habria que reemplazar la fila. Si se reemplaza quitarla
                                     * de filas (para no re-agregarla mas abajo)
                                     */

              for (var j=0; j<lenc; j++) {
                fila.push(filas[i][j]);
              }

              data2.push(fila);
            }
          }

          /* agregar filas blancas que falten */

          lenf = data.length - (lenf + numDataRows);
          this._addEmptyRows(data2, lenf, lenc);

          this.getGrid().getTableModel().setData(data2);
        }
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("Table2.addRows: " + e);
      }
    },


    /**
     * insertRows():
     *
     * @param filas {Array} vector de filas que se insertara
     * @param comienzo {Number} a partir de que numero de fila se insertan
     * @return {void} void
     */
    insertRows : function(filas, comienzo)
    {
      if (filas.length > 0)
      {
        this._setRenderers(filas[0]);
        this.getGrid().getTableModel().addRows(filas, comienzo);
      }
    },

    _addEmptyRows : function(mat, numFilas, numCols)
    {
      var filaDato = (mat.length > 0 ? mat[0] : false);

      for (var i=0; i<numFilas; i++)
      {
        var fila = new Array();

        for (var j=0; j<numCols; j++)
        {
          if (filaDato && (typeof (filaDato[j]) == "object"))
          {
            var h =
            {
              text  : " ",
              value : "-1"
            };

            fila.push(h);
          }
          else
          {
            fila.push(" ");
          }
        }

        mat.push(fila);
      }
    },


    /**
     * getData():
     *
     * @return {var} retorna matriz de datos (filtra vacias si las hay)
     */
    getData : function()
    {
      var d = this.getGrid().getTableModel().getData();
      var len = d.length;
      var len2 = (len > 0) ? d[0].length : 0;
      var ret = new Array();

      for (var i=0; i<len; i++)
      {
        if (this.isEmpty(d, i)) {
          break;
        }

        var fila = new Array();

        for (var j=0; j<len2; j++) {
          fila.push(d[i][j]);
        }

        ret.push(fila);
      }

      return ret;
    },


    /**
     * addEmptyRow():
     *
     * @return {var} true si agrego,sino false
     */
    addEmptyRow : function()
    {
      var ret = false;
      var tabla = this.getGrid();
      var ntabla = this._copyTableData();
      var cols = (ntabla.length > 0) ? ntabla[0].length : 0;

      if (cols > 0)
      {
        this._addEmptyRows(ntabla, 1, cols);

        /* this._doSetData(false,ntabla); */

        this.getGrid().getTableModel().setData(ntabla);
        this.setGridData(ntabla);
        ret = true;
      }

      return ret;
    },


    /**
     * _copyTableData():
     *
     * @return {var} retorna una copia de los datos
     */
    _copyTableData : function() {
      return inventario.widget.Table.copiarTabla(this.getGrid());
    },


    /**
     * getHashedData():
     *
     * @return {Array} de hashes
     */
    getHashedData : function()
    {
      var data = this.getGrid().getTableModel().getData();
      var len = data.length;
      var len2 = (len > 0) ? data[0].length : 0;
      var keys = this.getHashKeys();
      var ret = new Array();
      var addHash = false;

      if (len2 == keys.length)
      {
        for (var i=0; i<len; i++)
        {
          // if (this.getUseEmptyTable() && data[i][0] == " ") {
          if (this.isEmpty(data, i)) {
            break;
          }

          var h = {};

          for (var j=0; j<len2; j++)
          {
            if (keys[j])
            {
              var k = keys[j];

              if (typeof (data[i][j]) == "object") {
                h[k] = data[i][j].value;
              } else {
                h[k] = data[i][j];
              }

              addHash = true;
            }
          }

          if (addHash) {
            ret.push(h);
          }
        }
      } else {
	var error_str = qx.locale.Manager.tr("Didn't receive the correct number of parameters.");
        alert("getHashedData: tableObj.getHashKeys(): "+ error_str);
      }

      return ret;
    },


    /**
     * emptyTable(): Vaciar tabla
     *
     * @return {void} void
     */
    emptyTable : function()
    {
      if (!this.getUseEmptyTable()) {
        this.getGrid().getTableModel().setData([]);
      }
      else
      {

        /* OJO: this.getRowsNum() y this.getColsNum() podrian no estar bien.. */

        if (parseInt(this.getRowsNum()) > 0 && parseInt(this.getColsNum()) > 0)
        {
          var data = new Array();
          this._addEmptyRows(data, this.getRowsNum(), this.getColsNum());
          this.setGridData(data);
          this._setRenderers(data[0]);
          this.getGrid().getTableModel().setData(data);
        }
      }
    },


    /**
     * DEPRECATED: no llego a funcionar al final. Verificar si no se llama y bo-rrar-lo! (RGS)
     * 
     * _doSetData: Vaciar tabla
     *
     * @param activateHandlers {Boolean} dejar que se ejecuten los handlers de onDataChange
     * @param dataParam {Array} Si es null usamos this.getGridData()
     * @return {void} void
     */
    _doSetData : function(activateHandlers, dataParam)
    {
      var tm = this.getGrid().getTableModel();
      var data = (dataParam) ? dataParam : this.getGridData();

      if (!activateHandlers)
      {
        tm.removeListener("dataChanged", this._dataChangedHandler, this);  // empieza la contencion.. ignoramos eventos
        this.getGrid().getTableModel().setData(data);
        tm.addListener("dataChanged", this._dataChangedHandler, this);  // fin de contencion
      }
      else
      {
        this.getGrid().getTableModel().setData(data);
      }
    },

    deleteRow : function(e)
    {
      try
      {
        var data = this.getGrid().getTableModel().getData();
        var sm = this.getGrid().getSelectionModel();
        var len = this.getGrid().getTableModel().getRowCount();

        for (var i=len-1; i>=0; i--)
        {
          if (sm.isSelectedIndex(i) && !this.isEmpty(data, i))
          {
            this.getGrid().getTableModel().removeRows(i, 1);

            // si se borra una fila y si se reconce filas vacias se tiene que agregar una fila vacia
            if (this.getUseEmptyTable()) this.addEmptyRow();
          }
        }
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("Table2.deleteRow => " + e);
      }
    },

    getSeleccionadas : function()
    {
      var ret = new Array();
      var data = this.getGrid().getTableModel().getData();
      var sm = this.getGrid().getSelectionModel();
      var len = this.getGrid().getTableModel().getRowCount();

      for (var i=len-1; i>=0; i--)
      {
        if (sm.isSelectedIndex(i) && !this.isEmpty(data, i)) {
          ret.push(data[i]);
        }
      }

      return ret;
    },

    selectRow : function(e)
    {
      var sm = this.getGrid().getSelectionModel();
      var len = this.getData().length;

      if (len && parseInt(len) > 0) {
        sm.setSelectionInterval(0, len - 1);
      }
    },


    /**
     * isRowRepeated: chequear si
     *
     * @param row {Array} fila cuya version repetida se busca
     * @param filas {Array} vector de filas en donde buscar
     * @param col {Number} numero de columna para ver si existe
     * @return {var} boolean
     */
    isRowRepeated : function(row, filas, col)
    {
      var ret = false;
      var len = filas.length;

      for (var i=0; i<len; i++)
      {
        if (row[col] == filas[i][col])
        {
          ret = true;
          break;
        }
      }

      return ret;
    },


    /**
     * isEmpty: chequear si la fila esta vacia
     *
     * @param mat {Array} matriz
     * @param row {Number} numero de la fila
     * @return {var} boolean
     */
    isEmpty : function(mat, row) {
      return inventario.widget.Table2.isEmpty2(mat, row, this.getUseEmptyTable());
    },


    /**
     * isEmpty: chequear si la tabla
     *
     * @return {var} boolean
     */
    isTableEmpty : function() {
      return this.getData().length == 0;
    },


    /**
     * setCantidadDecimales:
     * 
     * TODO: buscar una manera mas elegante de hacer esto, estamos tocando una variable privada
     *
     * @param cantidad {var} TODOC
     * @return {var} void
     */
    setCantidadDecimales : function(cantidad)
    {
      var nf = new qx.util.format.NumberFormat();
      nf.setMaximumFractionDigits(cantidad);

      qx.ui.table.cellrenderer.Default._numberFormat = nf;
    }
  }
});
