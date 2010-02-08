
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
// MultipleHierarchySelection.js
// Selecting multiple items from the HierarchyOnDemand widget items.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Paraguay Educa 2009
qx.Class.define("inventario.widget.MultipleHierarchySelection",
{
  extend : qx.ui.container.Composite,

  /*
       * CONSTRUCTOR
       */

  construct : function(opts)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.VBox(3));
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(3));
      var hbox2 = new qx.ui.container.Composite(new qx.ui.layout.HBox(3));

      var hierarchy = new inventario.widget.HierarchyOnDemand(null, opts);
      var list = new qx.ui.form.List();

      if (typeof opts != "undefined" && opts != null)
      {
        list.setWidth(opts.width);
        list.setHeight(opts.height);
      }

      list.setScrollbarX("on");

      var addButton = new qx.ui.form.Button("Agregar");
      addButton.addListener("execute", this._addItem, this);
      var removeButton = new qx.ui.form.Button("Quitar");
      removeButton.addListener("execute", this._removeItem, this);

      // var testButton = new qx.ui.form.Button("test");
      // testButton.addListener("execute", function () { alert(this.getValues().toString()); }, this);
      hbox.add(hierarchy);
      hbox.add(list);

      hbox2.add(addButton);
      hbox2.add(removeButton);

      // hbox2.add(testButton);
      this.add(hbox);
      this.add(hbox2);

      this.setHierarchyWidget(hierarchy);
      this.setListWidget(list);
    }
    catch(e)
    {
      alert("MHS construct: " + e.toString());
    }
  },

  /*
       * PROPERTIES
       */

  properties :
  {
    hierarchyWidget :
    {
      check : "Object",
      init  : null
    },

    listWidget :
    {
      check : "Object",
      init  : null
    }
  },

  /*
       * MEMBERS
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
      var list = this.getListWidget();
      var elements = list.getChildren();

      var values = new Array;

      for (var i in elements) {
        values.push(Number(elements[i].getModel()));
      }

      return values;
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _addItem : function()
    {
      var hierarchy = this.getHierarchyWidget();
      var list = this.getListWidget();

      var label = hierarchy.getItemFullLabel();
      var value = hierarchy.getValue();
      var item = new qx.ui.form.ListItem(label, "icon/16/places/folder.png", value.toString());

      list.add(item);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _removeItem : function()
    {
      var list = this.getListWidget();
      var selected_item = list.getSelection()[0];

      list.remove(selected_item);
    }
  }
});
