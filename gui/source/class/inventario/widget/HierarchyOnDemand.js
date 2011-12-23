
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

/*
  #asset(qx/icon/Tango/16/places/user-desktop.png)
  #asset(qx/icon/Tango/16/status/dialog-information.png)
*/

qx.Class.define("inventario.widget.HierarchyOnDemand",
{
  extend : qx.ui.container.Composite,

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
      } else {
        this._requestElements();
      }
      tree.setHideRoot(true);
    }
    catch(e)
    {
      alert(e.toString());
    }
  },

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

  members :
  {
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

    setSize : function(width, height)
    {
      var tree = this.getTreeWidget();

      tree.set(
      {
        width  : width,
        height : height
      });
    },

    reLoadElements : function() {
      this._requestElements();
    },

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

    getElementData : function()
    {
      var selected_element = this.getTreeWidget().getSelection()[0];
      var element_data = selected_element.getUserData("data");
      return element_data;
    },

    isSubElement : function()
    {
      var selected_element = this.getTreeWidget().getSelection()[0];
      var type = selected_element.getUserData("sub_element");
      return type;
    },

    _newElement : function(data, callback, type, icon)
    {
      var new_element = new qx.ui.tree.TreeFolder();
      new_element.setOpen(true);
      new_element.addIcon();

      if (typeof icon == "undefined") {
        icon = "qx/icon/Tango/16/places/user-desktop.png";
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

    _populateElements : function(parent_element, new_elements)
    {
      for (var i in new_elements) {
        var element = this._newElement(new_elements[i], this._requestElements, false);
        parent_element.add(element);
        if (new_elements[i].children != undefined)
          this._populateElements(element, new_elements[i].children);
      }
    },

    _loadElements : function(remoteData, selected_element)
    {
      selected_element.removeAll();
      var new_elements = remoteData.elements;
      this._populateElements(selected_element, new_elements);

      var new_sub_elements = remoteData.sub_elements;

      for (var i in new_sub_elements) {
        selected_element.add(this._newElement(new_sub_elements[i], null, true, "qx/icon/Tango/16/status/dialog-information.png"));
      }

      selected_element.setOpen(true);
    },

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

    _recursiveLoad : function(selectedElement, hashData)
    {
      var new_element = this._newElement(hashData, this._requestElements, false);
      selectedElement.add(new_element);

      this.getTreeWidget().setSelection([new_element]);
      var new_elements = hashData.elements;

      for (var i in new_elements) {
        this._recursiveLoad(new_element, new_elements[i]);
      }
    }
  }
});
