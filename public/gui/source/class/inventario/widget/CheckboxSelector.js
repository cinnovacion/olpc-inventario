
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
// CheckboxSelector.js
// date: 2009-01-29
// author: rgs
//
// TODO: add orientation code
qx.Class.define("inventario.widget.CheckboxSelector",
{
  extend : qx.ui.container.Composite,

  /**
       *  
       * @param group_label {String} Name of this group of checkboxes
       * @param cb_array {Array} Format of the arr: [ { label : "aaa", cb_name : "aaa" } , ... ]
       * @return {Class Instance} 
       */
  construct : function(group_label, cb_array, max_column)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(20));

      // create grid layout
      var gl = new qx.ui.container.Composite(new qx.ui.layout.Grid());
      this._grid_layout = gl;
      this.add(gl);

      // title
      var hBox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));

      gl.add(hBox,
      {
        row    : 0,
        column : 0
      });

      hBox.add(new qx.ui.basic.Label(group_label));

      // Select and de-select all buttons.
      var allButton = new qx.ui.form.Button("+");

      allButton.addListener("execute", function() {
        this._setAllCheckedTo(true);
      }, this);

      var noneButton = new qx.ui.form.Button("-");

      noneButton.addListener("execute", function() {
        this._setAllCheckedTo(false);
      }, this);

      hBox.add(allButton);
      hBox.add(noneButton);

      this._row_num = 1;
      this._col_num = 0;

      // init cb array
      this.setCheckBoxArray(new Array());

      for (var i in cb_array)
      {
        var h = cb_array[i];
        this._addPart(h["label"], h["cb_name"], h["checked"]);

        if ((i % max_column) == max_column - 1)
        {
          this._row_num++;
          this._col_num = 0;
        }
      }
    }
    catch(e)
    {
      alert(e.toString());
    }
  },

  properties : { checkBoxArray : { check : "Object" } },

  members :
  {
    /**
     * getSelectedParts: returnes array of selected parts
     */
    getSelectedParts : function()
    {
      var ret = new Array();

      var len = this.getCheckBoxArray().length;

      for (var i=0; i<len; i++)
      {
        var cb = this.getCheckBoxArray()[i];

        if (cb.getValue()) {
          ret.push(cb.getUserData("cb_name"));
        }
      }

      return ret;
    },

    _addPart : function(label_text, cb_name, checked)
    {
      this._addToGrid(new qx.ui.basic.Label(label_text));

      var cb = new qx.ui.form.CheckBox();

      if (checked) {
        cb.setValue(true);
      }

      cb.setUserData("cb_name", cb_name);
      this.getCheckBoxArray().push(cb);
      this._addToGrid(cb);
    },

    // TODO: add layout code
    _addToGrid : function(addObj)
    {
      this._grid_layout.add(addObj,
      {
        row    : this._row_num,
        column : this._col_num
      });

      this._col_num++;
    },

    _setAllCheckedTo : function(state)
    {
      var cb_array = this.getCheckBoxArray();
      var cb_a_len = cb_array.length;

      for (var i=0; i<cb_a_len; i++) {
        cb_array[i].setValue(state ? true : false);
      }
    }
  }
});
