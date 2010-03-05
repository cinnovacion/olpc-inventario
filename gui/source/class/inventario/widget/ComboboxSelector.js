
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
// ComboboxSelector.js
// date: 2009-01-30
// author: rgs
//
// TODO: add orientation code
qx.Class.define("inventario.widget.ComboboxSelector",
{
  extend : qx.ui.container.Composite,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  /**
       *  
       * @param cb_label {String} Label that goes next to the combobox
       * @param cb_options {Array} Combobox options: [ { text : "aaa", value : "aaa" } , ... ]
       * @return {Class Instance} 
       */
  construct : function(cb_label, cb_options, width)
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
      var cb = new qx.ui.form.SelectBox();

      var internal_width = 130;

      if (typeof width != "undefined") {
        internal_width = width;
      }

      cb.setWidth(internal_width);

      this.setComboBox(cb);
      inventario.widget.Form.loadComboBox(cb, cb_options, true);

      gl.add(cb,
      {
        row    : 0,
        column : 1
      });

      // testing
      if (this.getDebug())
      {
        var but = new qx.ui.form.Button(qx.locale.Manager.tr("View Selections "));
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




  /*
      *****************************************************************************
         PROPERTIES
      *****************************************************************************
      */

  properties :
  {
    comboBox : { check : "Object" },

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
     * getSelectedValue: returns selected value
     *
     * @return {Map} TODOC
     */
    getSelectedValue : function()
    {
      var cb = this.getComboBox();
      return inventario.widget.Form.getInputValue(cb);
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _view_selection_cb : function(e)
    {
      var v = this.getSelectedValue();
      alert(qx.locale.Manager.tr("See: ") + v.toString());
    }
  }
});
