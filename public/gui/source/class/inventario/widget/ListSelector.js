
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
// ListSelector.js
// date: 2009-01-30
// author: rgs
//
// TODO: add orientation code
qx.Class.define("inventario.widget.ListSelector",
{
  extend : qx.ui.container.Composite,

  /**
       *  
       * @param cb_label {String} Label that goes next to the combobox
       * @param list_name {String} Internal name of an Abm2 list
       * @return {Class Instance} 
       */
  construct : function(cb_label, list_name)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(20));

      // create grid layout
      var gl = new qx.ui.container.Composite(new qx.ui.layout.Grid());
      this._grid_layout = gl;
      this.add(gl);

      // title
      gl.add(new qx.ui.basic.Label(cb_label),
      {
        row    : 0,
        column : 0
      });

      // combobox
      var cb_select = new inventario.widget.Select(list_name);
      this.setComboBox(cb_select.getComboBox());

      gl.add(cb_select,
      {
        row    : 0,
        column : 1
      });

      // testing
      if (this.getDebug())
      {
        var but = new qx.ui.form.Button("Ver seleccion");
        but.addListener("execute", this._view_selection_cb, this);

        gl.add(but,
        {
          row    : 0,
          column : 2
        });
      }
    }
    catch(e)
    {
      alert(e.toString());
    }
  },

  properties :
  {
    comboBox : { check : "Object" },

    debug :
    {
      check : "Boolean",
      init  : false
    }
  },

  members :
  {
    /**
     * getSelectedValue: returns selected value
     */
    getSelectedValue : function()
    {
      var cb = this.getComboBox();
      return inventario.widget.Form.getInputValue(cb);
    },

    _view_selection_cb : function(e)
    {
      var v = this.getSelectedValue();
      alert(qx.locale.Manager.tr("See: ") + v.toString());
    }
  }
});
