
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
// ColumnValueSelector.js
// date: 2009-01-30
// author: rgs
//
qx.Class.define("inventario.widget.ColumnValueSelector",
{
  extend : qx.ui.container.Composite,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  /**
       *  
       * @param column_options {Array} Array with options [ { datatype : "textfield", text : "Col1", value : "col_name"  } ] 
       * @return {Class Instance} 
       */
  construct : function(column_options)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(20));

      this._column_options = column_options;
      this._row_num = 0;

      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20), { height : 50 });
      this.add(vbox);

      // create grid layout
      var gl = new qx.ui.container.Composite(new qx.ui.layout.Grid());
      this._grid_layout = gl;
      vbox.add(gl);

      this._addRow();

      var but = new qx.ui.form.Button("+");
      but.addListener("execute", this._add_row_cb, this);
      vbox.add(but);

      // testing
      if (this.getDebug())
      {
        var but = new qx.ui.form.Button(qx.locale.Manager.tr("See values"));
        but.addListener("execute", this._show_values_cb, this);
        vbox.add(but);
      }
    }
    catch(e)
    {
      alert(e.toString());
    }
  },




  /*
      *****************************************************************************
         PROPERTIES
      *****************************************************************************
      */

  properties :
  {
    debug :
    {
      check : "Boolean",
      init  : false
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
     * TODOC
     *
     * @return {var} TODOC
     */
    getValues : function()
    {
      var ret = new Array();
      var cells = this._grid_layout.getChildren();

      for (var i=0; i<this._row_num; i++)
      {
        var j = i * 3;
        var cb = cells[j];
        var tf = cells[j + 1];

        var h = {};
        h["col_name"] = inventario.widget.Form.getInputValue(cb);
        h["value"] = inventario.widget.Form.getInputValue(tf);

        ret.push(h);
      }

      return ret;
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _addRow : function()
    {
      var row_num = this._row_num;
      var gl = this._grid_layout;

      var cb = new qx.ui.form.SelectBox();  // TODO: set handler to dynamically change value column
      inventario.widget.Form.loadComboBox(cb, this._column_options, true);

      gl.add(cb,
      {
        row    : row_num,
        column : 0
      });

      var textfield = new qx.ui.form.TextField();

      gl.add(textfield,
      {
        row    : row_num,
        column : 1
      });

      var but = new qx.ui.form.Button("-");
      but.addListener("execute", this._remove_row_cb, this);

      gl.add(but,
      {
        row    : row_num,
        column : 2
      });

      this._row_num++;
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _add_row_cb : function() {
      this._addRow();
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _remove_row_cb : function(e)
    {
      var start_w = this._grid_layout.indexOf(e.getTarget()) - 2;

      for (var i=0; i<3; i++) {
        this._grid_layout.removeAt(start_w);
      }

      this._row_num--;
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _show_values_cb : function(e)
    {
      var values = this.getValues();
      var s = qx.util.Json.stringify(values);
      alert(s);
    }
  }
});
