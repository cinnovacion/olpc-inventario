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
// Window.js
// author: Raul Gutierrez S. - rgs@paraguayeduca.org
//

/*
  #asset(qx/icon/Tango/22/actions/document-new.png)
*/

qx.Class.define("inventario.widget.Window",
{
  extend : qx.core.Object,


  construct : function(param)
  {
    var title = "";

    if (param)
    {
      if (typeof (param) == "object")
      {
        if (param["title"]) {
          title = param["title"];
        }

        if (param["height"]) {
          this.setHeight(parseInt(param["height"]));
        }

        if (param["width"]) {
          this.setWidth(parseInt(param["width"]));
        }
      }
      else
      {
        title = param;
      }
    }

    this.setTitle(title);

    var win = new qx.ui.window.Window(this.getTitle(), this.getIcon());


    win.addListenerOnce("appear", function(e) {
      win.center();
    });

    win.setLayout(new qx.ui.layout.VBox(10));
    this.setWindow(win);

    var width = this.getWidth();
    var height = this.getHeight();
    win.setMinWidth(width);
    win.setMinHeight(height);
    win.setShowClose(true);
    win.setShowMaximize(false);

    var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));
    this.setVbox(vbox);

    win.add(vbox);
  },



  properties :
  {
    window :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    vbox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    width :
    {
      check : "Number",
      init  : 400
    },

    height :
    {
      check : "Number",
      init  : 200
    },

    relatedObj :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    title :
    {
      check : "String",
      init  : ""
    },

    icon :
    {
      check : "String",
      init  : "icon/22/actions/document-new.png"
    },

    onCloseCallBack :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    onCloseCallBackContext :
    {
      check    : "Object",
      init     : null,
      nullable : true
    }
  },


  members :
  {
    /**
     * TODOC
     *
     * @param title {String} titulo de la ventana
     * @return {void} void
     */
    show : function(title)
    {
      var win = this.getWindow();
      if (title) win.setCaption(title);

      var func = this.getOnCloseCallBack();

      if (func)
      {
        var contexto = this.getOnCloseCallBackContext();
        var objWin = this;

        var f = function(e)
        {
          var huboCambios = false;
          var obj = objWin.getRelatedObj();

          if (obj) {
            huboCambios = obj.getSavedChanges();
          }

          func.call(contexto, huboCambios);
        };

        win.addListener("disappear", f, contexto);
      }

      var width = this.getWidth();
      var height = this.getHeight();
      win.setMinWidth(width);
      win.setMinHeight(height);
      win.open();
    }
  }
});
