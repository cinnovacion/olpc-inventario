
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
// HierarchyOnDemand.js
// Its basically a tree loaded by the user on demand.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Paraguay Educa 2009
qx.Class.define("inventario.widget.HierarchyOnDemand",
{
  extend : qx.ui.container.Composite,

  /*
       * CONSTRUCTOR
       */

  construct : function(dataHash, opts)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(20));

      var tree = new qx.ui.tree.Tree();

      tree.set(
      {
        width  : 300,
        height : 150
      });

      var root = this._newElement(
      {
        id   : -1,
        text : "*"
      },
      this._requestElements, false);

      tree.setRoot(root);
      //tree.select(root);
      tree.setSelection([root]);


      if (typeof opts != "undefined" && opts != null)
      {
        if (typeof opts.label != "undefined") {
          this.add(new qx.ui.basic.Label(opts.label));
        }

        if (typeof opts.width != "undefined" && typeof opts.height != "undefined")
        {
          tree.set(
          {
            width  : opts.width,
            height : opts.height
          });
        }
      }

      this.add(tree);
      this.setTreeWidget(tree);
      this.setSubElementTags(new Array());

      if (typeof dataHash != "undefined" && dataHash != null) {
        this._recursiveLoad(root, dataHash);
      }
    }
    catch(e)
    {
      alert(e.toString());
    }
  },

  /*
       * PROPERTIES
       */

  properties :
  {
    treeWidget :
    {
      check    : "Object",
      nullable : true,
      init     : null
    },

    requestElementsUrl :
    {
      check : "String",
      init  : "/places/requestElements"
    },

    subElementTags :
    {
      check    : "Object",
      nullable : true,
      init     : null
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
    getItemFullLabel : function()
    {
      var tree = this.getTreeWidget();
      var selected_element = this.getTreeWidget().getSelection()[0];
      var parent_element = selected_element.getParent();

      var label = selected_element.getLabel();

      while (parent_element != null)
      {
        label = parent_element.getLabel() + ":" + label;
        parent_element = parent_element.getParent();
      }

      return label;
    },


    /**
     * TODOC
     *
     * @param width {var} TODOC
     * @param height {var} TODOC
     * @return {void} 
     */
    setSize : function(width, height)
    {
      var tree = this.getTreeWidget();

      tree.set(
      {
        width  : width,
        height : height
      });
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    reLoadElements : function() {
      this._requestElements();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    reLoadParentElements : function()
    {
      var tree = this.getTreeWidget();
      var selected_element = this.getTreeWidget().getSelection()[0];
      var parent_element = selected_element.getParent();

      if (parent_element != null)
      {
        tree.setSelection([parent_element]);
        this._requestElements();
      }
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    getValue : function()
    {
      var ret = -1;
      var selected_element = this.getTreeWidget().getSelection()[0];

      if (typeof selected_element != "undefined")
      {
        var element_data = selected_element.getUserData("data");
        ret = Number(element_data.id);
      }

      // alert(ret.toString());
      return ret;
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    getElementData : function()
    {
      var selected_element = this.getTreeWidget().getSelection()[0];
      var element_data = selected_element.getUserData("data");
      return element_data;
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    isSubElement : function()
    {
      var selected_element = this.getTreeWidget().getSelection()[0];
      var type = selected_element.getUserData("sub_element");
      return type;
    },


    /**
     * TODOC
     *
     * @param data {var} TODOC
     * @param callback {var} TODOC
     * @param type {var} TODOC
     * @param icon {var} TODOC
     * @return {var} TODOC
     */
    _newElement : function(data, callback, type, icon)
    {
      var new_element = new qx.ui.tree.TreeFolder();
      new_element.setOpen(true);
      new_element.addIcon();

      if (typeof icon == "undefined") {
        icon = "icon/16/places/user-desktop.png";
      }

      new_element.setIcon(icon);

      new_element.addLabel(data.text);
      new_element.setUserData("data", data);
      new_element.setUserData("sub_element", type);

      if (callback != null) {
        new_element.addListener("dblclick", callback, this);
      }

      return new_element;
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param selected_element {var} TODOC
     * @return {void} 
     */
    _loadElements : function(remoteData, selected_element)
    {
      selected_element.removeAll();

      new_elements = remoteData.elements;

      for (var i in new_elements) {
        selected_element.add(this._newElement(new_elements[i], this._requestElements, false));
      }

      new_sub_elements = remoteData.sub_elements;

      for (var i in new_sub_elements) {
        selected_element.add(this._newElement(new_sub_elements[i], null, true, "icon/16/status/dialog-information.png"));
      }

      selected_element.setOpen(true);
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _requestElements : function(e)
    {
      var subElementTags = this.getSubElementTags();
      var selected_element = this.getTreeWidget().getSelection()[0];
      var element_data = selected_element.getUserData("data");

      var data =
      {
        id             : element_data.id,
        subElementTags : qx.util.Json.stringify(subElementTags)
      };

      var hopts = {};
      hopts.url = this.getRequestElementsUrl();
      hopts.parametros = selected_element;
      hopts.handle = this._loadElements;
      hopts.data = data;

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param selectedElement {var} TODOC
     * @param hashData {var} TODOC
     * @return {void} 
     */
    _recursiveLoad : function(selectedElement, hashData)
    {
      var new_element = this._newElement(hashData, this._requestElements, false);
      selectedElement.add(new_element);

      this.getTreeWidget().setSelection(new_element);
      var new_elements = hashData.elements;

      for (var i in new_elements) {
        this._recursiveLoad(new_element, new_elements[i]);
      }
    }
  }
});
