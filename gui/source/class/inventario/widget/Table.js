
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
  extend : qx.core.Object,

  construct : function(page) {},

  statics :
  {
    /**
     * TODOC
     *
     * @param table {var} TODOC
     * @return {var} TODOC
     */
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

    /**
     * TODOC
     *
     * @param t {var} TODOC
     * @return {var} TODOC
     */
    copiarTablaSlice : function(t)
    {
      var ret = new Array();
      var len = (t ? t.length : 0);

      for (var i=0; i<len; i++) {
        ret.push(t[i].slice());
      }

      return ret;
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
      var titulo = [];
      for (var i=0; i<vdata.length; i++) titulo.push(vdata[i]["titulo"]);
      var tableModel = new qx.ui.table.model.Simple();
      tableModel.setColumns(titulo);
      for (var i=0; i<vdata.length; i++) tableModel.setColumnEditable(i, vdata[i]["editable"]);
      var table = new qx.ui.table.Table(tableModel);

      if (typeof width != "undefined" && width != null) {
        table.setWidth(width);
      }

      if (typeof height != "undefined" && height != null) {
        table.setHeight(height);
      }

      table.setStatusBarVisible(false);

      for (var i=0; i<vdata.length; i++) {
	table.setColumnWidth(i, vdata[i]["width"]);
	if (vdata[i]["renderer"]) table.getTableColumnModel().setDataCellRenderer(i, new vdata[i]["renderer"]);
	if (vdata[i]["factory"]) table.getTableColumnModel().setCellEditorFactory(i, new vdata[i]["factory"]);
      }

      table.getSelectionModel().setSelectionMode(qx.ui.table.selection.Model.MULTIPLE_INTERVAL_SELECTION);

      return table;
    },


    /**
     * getVisibleData(): returns the table data composed only of visible columns
     * 
     *  FIXME: this is very very inefficient.
     *
     * @param table {qx.ui.table.Table} TODOC
     * @return {var} table {Array of Array}
     */
    getVisibleData : function(table)
    {
      var tm = table.getTableModel();
      var allData = tm.getData();
      var visibleData = new Array();
      var row_count = allData ? allData.length : 0;
      var col_count = tm.getColumnCount();
      var tcm = table.getTableColumnModel();

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
     * @param table {qx.ui.table.Table} TODOC
     * @return {var} table {Array}
     */
    getVisibleColumnNames : function(table)
    {
      var col_names = new Array();
      var tm = table.getTableModel();
      var col_count = tm.getColumnCount();
      var tcm = table.getTableColumnModel();

      for (var i=0; i<col_count; i++) {
        if (tcm.isColumnVisible(i)) {
          col_names.push(tm.getColumnName(i));
        }
      }

      return col_names;
    },


    /**
     * createTable2(): crear una tabla. Wrapper de createTable(). Normalmente dentro de loadInitialData()
     *
     * @param titles {Array} vector de titulos
     * @param options {Hash} hash de opciones
     * @return {var} table {qx.ui.table.Table}
     */
    createTable2 : function(titles, options)
    {
      var h = new Array();
      var len = titles.length;

      for (var i=0; i<len; i++)
      {
        var width = (options["widths"] && parseInt(options["widths"][i])) ? parseInt(options["widths"][i]) : 100;
        var editable = (options["editables"] && options["editables"][i]) ? options["editables"][i] : false;

        h.push(
        {
          titulo   : titles[i],
          editable : editable,
          width    : width
        });
      }

      var width = options["width"] ? options["width"] : "100%";
      var height = options["height"] ? options["height"] : "50%";
      var table = inventario.widget.Table.createTable(h, width, height);
      return table;
    },


    /**
     * Reemplaza a getSelected, no hace diferencia entre objects(hashes) y values (strings o ints)
     * 
     * Retorna los datos de las filas seleccionas, con todas las columnas o toda la columna
     *
     * @param tabla {var} TODOC
     * @param col {Array} un vector de interos dondes especificamos que columnas queremos obtener
     * @param allRows {Boolean} todas las filas?
     * @return {Array} es una matriz de la tablas
     */
    getSelected2 : function(tabla, col, allRows) {
      var ret = new Array();
      var sm = tabla.getSelectionModel();
      var tm = tabla.getTableModel();
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
     * Verifica que filas estan seleccionadeas y devuelve el valor en la misma posicion de
     *
     * @param tabla {var} TODOC
     * @param allRows {var} TODOC
     * @param mappingArray {var} TODOC
     * @return {var} TODOC
     */
    getMappedIds : function(tabla, allRows, mappingArray)
    {
      var ids = inventario.widget.Table.getSelected2(tabla, [ 0 ], true);
      var ret = new Array();
      var len = ids.length;
      var len2 = mappingArray.length;

      for (var i=0; i<len; i++) {
        var val = false;

        for (var j=0; j<len2; j++) {
          if (ids[i] == mappingArray[j]["id_visible"]) {
            val = mappingArray[j]["id_real"];
            break;
          }
        }

        if (val) {
          ret.push(val);
          if (!allRows) {
            break;
          }
        }
      }

      return ret;
    },


    /**
     * Borra una fila de la tabla
     *
     * @param table {qx.ui.table.Table} TODOC
     * @param row {Integer} TODOC
     * @return {void} 
     */
    removeRow : function(table, row)
    {
      var tableData = table.getTableModel().getData();
      qx.lang.Array.removeAt(tableData, row);
      table.getTableModel().setData(tableData);
    },


    /**
     * Agrega una fila de datos a la tabla
     *
     * @param table {qx.ui.table.Table} La table de donde se quiere obtener los datos
     * @param nData {Array} La nueva fila
     * @param col {var} La columna con la cual hay que comparar para ver si estamos modificando una fila o haciendo append
     * @return {var} true si agrego; false si reemplazo
     */
    addRow : function(table, nData, col)
    {
      var tableData = table.getTableModel().getData();
      var i = -1;  // indice en el cual habria que reemplazar la fila
      var ret;

      if (col != -1) {
        i = inventario.widget.Table.existsInTable(table, nData[col], col);
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

      table.getTableModel().setData(tableData);
      return ret;
    },


    /**
     * Agrega varias filas de datos a la tabla
     *
     * @param table {qx.ui.table.Table} La table de donde se quiere obtener los datos
     * @param nData {Array} matriz
     * @param col {var} La columna con la cual hay que comparar para ver si estamos modificando una fila o haciendo append
     * @return {void} true o false
     */
    addRows : function(table, nData, col)
    {
      var len = nData.length;
      for (var i=0; i<len; i++) inventario.widget.Table.addRow(table, nData[i], col);
    },


    /**
     * Verifica si una fila ya existe en una tabla
     *
     * @param table {qx.ui.table.Table} La table de donde se quiere obtener los datos
     * @param cell {Object o simple data type(string,int,etc.)} La celda
     * @param col {var} La columna con la cual hay que comparar para ver si estamos modificando una fila o haciendo append
     * @return {var} -1 si no existe o el indice
     */
    existsInTable : function(table, cell, col)
    {
      var tableData = table.getTableModel().getData();
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
     * Helper p/ construccion de tablas
     *
     * @param pInput {var} El input (combobox) del cual quitaremos los datos
     * @return {Map} hash {text,value}
     */
    getTextValue : function(pInput)
    {
      var val = -1;
      var text = " ";

      var sel = pInput.getSelected();

      if (sel)
      {
        val = sel.getValue();

        var field = pInput.getField();

        if (field) {
          text = field.getValue();
        }
      }

      return {
        value : val,
        text  : text
      };
    },


    /**
     * emptyTable(): Vaciar tabla
     *
     * @param table {qx.ui.table.Table} TODOC
     * @return {boolean} void
     */
    emptyTable : function(table)
    {
      table.getTableModel().setData([]);
      return true;
    },


    /**
     * convertToNum(): Vaciar tabla
     *
     * @param table {qx.ui.table.Table} TODOC
     * @param cols {var} columnas que hay que convetir a numero
     * @return {void} void
     */
    convertToNum : function(table, cols)
    {
      var len = table.length;

      for (var i=0; i<len; i++)
      {
        var len2 = cols.length;

        for (var j=0; j<len2; j++)
        {
          var x = cols[j];
          table[i][x] = parseFloat(table[i][x]);
        }
      }
    },


    /**
     * setRenderers(): establecer renderers de las columnas
     *
     * @param table {qx.ui.table.Table} TODOC
     * @param row {Array} una fila  para ver que tipo de datos tiene
     * @return {void} void
     */
    setRenderers : function(table, row)
    {
      var len = row.length;
      var tcm = table.getTableColumnModel();

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
