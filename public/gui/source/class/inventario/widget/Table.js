
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
// Table.js
//
qx.Class.define("inventario.widget.Table",
{
  extend : qx.ui.table.Table,

  construct : function(vdata) {
    var titulo = [];
    for (var i=0; i<vdata.length; i++) titulo.push(vdata[i]["titulo"]);
    this._tableModel = new qx.ui.table.model.Simple();
    this._tableModel.setColumns(titulo);
    this.base(arguments, this._tableModel);

    for (var i=0; i < vdata.length; i++) {
      var col = vdata[i];
      this._tableModel.setColumnEditable(i, col.editable);
      if ("visible" in col)
        this.getTableColumnModel().setColumnVisible(i, col.visible);
      if ("sortable" in col)
        this._tableModel.setColumnSortable(i, col.sortable);

      this.setColumnWidth(i, col.width);
      if (col.renderer) this.getTableColumnModel().setDataCellRenderer(i, new col.renderer);
      if (col.factory) this.getTableColumnModel().setCellEditorFactory(i, new col.factory);

      /* because we do sorting and data selection on the server, we want
       * to disable qooxdoo's sorting and instead pull in new data from the
       * server, while retaining qx's UI elements indicating sort column. */
      this._tableModel.setSortMethods(i, {ascending: inventario.widget.Table.dummySort, descending: inventario.widget.Table.dummySort});
    }

    this.getSelectionModel().setSelectionMode(qx.ui.table.selection.Model.MULTIPLE_INTERVAL_SELECTION);
    this.setStatusBarVisible(false);
  },

  destruct : function() {
    this._disposeObjects("_tableModel");
  },

  statics :
  {
    copiarTabla : function(table)
    {
      var data = table.getTableModel().getData();
      var lenf = data.length;
      var lenc = (lenf > 0) ? data[0].length : 0;
      var data2 = new Array();

      for (var i=0; i<lenf; i++) {
        var fila = new Array();

        for (var j=0; j<lenc; j++) {
          fila.push(data[i][j]);
        }

        data2.push(fila);
      }

      return data2;
    },

    dummySort : function(row1, row2)
    {
      /* next item always comes after */
      return -1;
    },

    /**
     * createTable() : creates a table, with all its parameters
     *
     * @param vdata {var} TODOC
     * @param width {var} TODOC
     * @param height {var} TODOC
     * @return {var} TODOC
     *
     * FIXME: horrible piece of code! Needs indentation and reorganization!
     */
    createTable : function(vdata, width, height)
    {
      var table = new inventario.widget.Table(vdata);

      if (typeof width != "undefined" && width != null) {
        table.setWidth(width);
      }

      if (typeof height != "undefined" && height != null) {
        table.setHeight(height);
      }

      return table;
    }
  },

  members :
  {
    /**
     * getVisibleData(): returns the table data composed only of visible columns
     * 
     *  FIXME: this is very very inefficient.
     *
     * @return {var} table {Array of Array}
     */
    getVisibleData : function()
    {
      var tm = this.getTableModel();
      var allData = tm.getData();
      var visibleData = new Array();
      var row_count = allData ? allData.length : 0;
      var col_count = tm.getColumnCount();
      var tcm = this.getTableColumnModel();

      for (var i=0; i<row_count; i++) {
        var row = new Array();

        for (var j=0; j<col_count; j++) {
          if (tcm.isColumnVisible(j)) {
            row.push(allData[i][j]);
          }
        }

        if (row.length > 0) {
          visibleData.push(row);
        }
      }

      return visibleData;
    },

    /**
     * getVisibleColumnNames(): returns the names of visible columns
     *
     * @return {var} table {Array}
     */
    getVisibleColumnNames : function()
    {
      var col_names = new Array();
      var tm = this.getTableModel();
      var col_count = tm.getColumnCount();
      var tcm = this.getTableColumnModel();

      for (var i=0; i<col_count; i++) {
        if (tcm.isColumnVisible(i)) {
          col_names.push(tm.getColumnName(i));
        }
      }

      return col_names;
    },

    /**
     * Reemplaza a getSelected, no hace diferencia entre objects(hashes) y values (strings o ints)
     * 
     * Retorna los datos de las filas seleccionas, con todas las columnas o toda la columna
     *
     * @param col {Array} un vector de interos dondes especificamos que columnas queremos obtener
     * @param allRows {Boolean} todas las filas?
     * @return {Array} es una matriz de la tablas
     */
    getSelected2 : function(col, allRows) {
      var ret = new Array();
      var sm = this.getSelectionModel();
      var tm = this.getTableModel();
      var len = tm.getRowCount();
      var lenCol = col ? col.length : 0;

      for (var i=0; i<len; i++) 
	if (sm.isSelectedIndex(i)) {
	  if (!col) 
	    ret.push(tm.getRowData(i));
	  else {
	    if (lenCol > 1) {
	      var tmp = [];

	      for (var j in col) {
		var v = tm.getValue(j, i);
		tmp.push(v);
	      }

	      ret.push(tmp);
	    } else {
	      var v = tm.getValue(col[0], i);
	      ret.push(v);
	    }
	  }

	  if (!allRows) {
	    break;
	  }
	}

      return ret;
    },

    /**
     * Agrega una fila de datos a la tabla
     *
     * @param table {qx.ui.table.Table} La table de donde se quiere obtener los datos
     * @param nData {Array} La nueva fila
     * @param col {var} La columna con la cual hay que comparar para ver si estamos modificando una fila o haciendo append
     * @return {var} true si agrego; false si reemplazo
     */
    addRow : function(nData, col)
    {
      var tableData = this.getTableModel().getData();
      var i = -1;  // indice en el cual habria que reemplazar la fila
      var ret;

      if (col != -1) {
        i = this.existsInTable(nData[col], col);
      }

      if (i >= 0)
      {
        tableData[i] = nData;
        ret = false;
      }
      else
      {
        tableData.push(nData);
        ret = true;
      }

      this.getTableModel().setData(tableData);
      return ret;
    },


    /**
     * Agrega varias filas de datos a la tabla
     *
     * @param nData {Array} matriz
     * @param col {var} La columna con la cual hay que comparar para ver si estamos modificando una fila o haciendo append
     * @return {void} true o false
     */
    addRows : function(nData, col)
    {
      var len = nData.length;
      for (var i=0; i<len; i++) this.addRow(nData[i], col);
    },


    /**
     * Verifica si una fila ya existe en una tabla
     *
     * @param table {qx.ui.table.Table} La table de donde se quiere obtener los datos
     * @param cell {Object o simple data type(string,int,etc.)} La celda
     * @param col {var} La columna con la cual hay que comparar para ver si estamos modificando una fila o haciendo append
     * @return {var} -1 si no existe o el indice
     */
    existsInTable : function(cell, col)
    {
      var tableData = this.getTableModel().getData();
      var len = tableData.length;
      var ret = -1;

      if (typeof (cell) == "object")
      {
        for (var i=0; i<len; i++)
        {
          var r = tableData[i][col];

          if (r.value == cell.value)
          {
            ret = i;
            break;
          }
        }
      }
      else
      {
        for (var i=0; i<len; i++)
        {
          var r = tableData[i][col];

          if (r == cell)
          {
            ret = i;
            break;
          }
        }
      }

      return ret;
    },

    /**
     * setRenderers(): establecer renderers de las columnas
     *
     * @param row {Array} una fila  para ver que tipo de datos tiene
     * @return {void} void
     */
    setRenderers : function(row)
    {
      var len = row.length;
      var tcm = this.getTableColumnModel();

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
    }
  }
});
