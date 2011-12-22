
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
qx.Class.define("inventario.widget.DynTable",
{
  extend : qx.ui.container.Composite,

  construct : function(tableDef, columnsData) {
    this.base(arguments, new qx.ui.layout.VBox(20));
    this.setTableDef(tableDef);
    this.setColumnsData(columnsData);

    var columns_hbox = this._getColumnsInputs();
    this.add(columns_hbox);

    var table_hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
    this._getTable(table_hbox);
    this.add(table_hbox);
  },

  properties :
  {
    columnsData :
    {
      check : "Object",
      init  : null
    },

    tableDef :
    {
      check : "Object",
      init  : null
    },

    dataInputs :
    {
      check : "Object",
      init  : null
    },

    tableObj :
    {
      check : "Object",
      init  : null
    }
  },

  members :
  {
    getTableData : function() {
      return this.getTableObj().getHashedData();
    },

    setTableData : function(tableData)
    {
      if (tableData) {
        this.getTableObj().addRows(tableData, -1);
      }
    },

    _getColumnsInputs : function()
    {
      var grid = new qx.ui.container.Composite(new qx.ui.layout.Grid());
      var len = this.getColumnsData().length;

      this.setDataInputs(new Array());

      var i;

      for (i=0; i<len; i++)
      {
        var col = this.getColumnsData()[i];
        var input = this._createDataInput(col);

        grid.add(new qx.ui.basic.Label(col.label),
        {
          row    : i,
          column : 0
        });

        grid.add(input,
        {
          row    : i,
          column : 1
        });

        this.getDataInputs().push(input);
      }

      grid.add(this._getAddButton(),
      {
        row    : i,
        column : 0
      });

      return grid;
    },

    _createDataInput : function(col)
    {
      var retInput;

      switch(col.datatype)
      {
        case "textfield":
          retInput = new qx.ui.form.TextField();
          break;

        case "combobox":
          retInput = new qx.ui.form.SelectBox();
          inventario.widget.Form.loadComboBox(retInput, col.options, true);
          break;

        case "select":
          retInput = new inventario.widget.Select(col.select_name);
          break;

        case "hierarchy_on_demand":
          retInput = new inventario.widget.HierarchyOnDemand(null, col.options);
          break;

        case "date":
          retInput = new qx.ui.form.DateField();
          break;

        default:
          alert(qx.locale.Manager.tr("do not know the datatype : ") + col.datatype);
      }

      return retInput;
    },

    _getAddButton : function()
    {
      var but = new qx.ui.form.Button("+");
      but.addListener("execute", this._add_row_cb, this);

      return but;
    },

    _getTable : function(hbox)
    {
      var rows_num = 5;  // TODO: has to be a settable property
      var tableObj = new inventario.widget.Table2();

      tableObj.setTableHeight(150);
      tableObj.setTableWidth(300);
      tableObj.setPage(hbox);
      tableObj.setUseEmptyTable(true);
      tableObj.setRowsNum(rows_num);
      tableObj.setColsNum(this.getTableDef().col_titles.length);
      tableObj.setTitles(this.getTableDef().col_titles);

      if (this.getTableDef().editables) tableObj.setEditables(this.getTableDef().editables);

      if (this.getTableDef().widths) tableObj.setWidths(this.getTableDef().widths);

      if (this.getTableDef().columnas_visibles) tableObj.setColumnasVisibles(this.getTableDef().columnas_visibles);

      tableObj.setWithButtons(true);
      tableObj.setShowDeleteButton(true);

      tableObj.setShowAddButton(false);
      tableObj.setShowSelectButton(false);
      tableObj.setShowModifyButton(false);
      tableObj.setDeleteButtonLabel("-");
      tableObj.setDeleteButtonIcon("");

      tableObj.setHashKeys(this.getTableDef().hashed_data);

      tableObj.show();  // FIXME: necessary?

      this.setTableObj(tableObj);

      return tableObj;
    },

    _add_row_cb : function(e)
    {
      var row = this._getRowData();
      this.getTableObj().addRows([ row ], -1);
    },

    _getRowData : function()
    {
      var inputs = this.getDataInputs();
      var len = inputs.length;
      var ret = new Array();
      var v;

      for (var i=0; i<len; i++)
      {
        v = inventario.widget.Form.getInputValue(inputs[i], true);
        ret.push(v);
      }

      return ret;
    }
  }
});
