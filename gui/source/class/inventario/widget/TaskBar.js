
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
// TaskBar.js
// Very simple Taskbar
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Paraguay Educa 2009
qx.Class.define("inventario.widget.TaskBar",
{
  type : "singleton",
  extend : qx.ui.container.Composite,

  /*
       * CONSTRUCTOR
       */

  construct : function()
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(20));

      // We create all the layouts.
      var leftHbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      this.add(leftHbox, { flex : 1 });
      this.setLeftHbox(leftHbox);

      var mainHbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      this.add(mainHbox, { flex : 10 });

      var rightHbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      this.add(rightHbox, { flex : 1 });
      this.setRightHbox(rightHbox);

      var toolBar = new qx.ui.toolbar.ToolBar();
      var part = new qx.ui.toolbar.Part();

      toolBar.add(part);

      mainHbox.add(toolBar, { flex : 1 });

      this.setToolBar(toolBar);
      this.setPart(part);
    }
    catch(e)
    {
      alert("Constructor: " + e.toString());
    }
  },

  /*
       * PROPERTIES
       */

  properties :
  {
    toolBar :
    {
      check : "Object",
      init  : null
    },

    part :
    {
      check : "Object",
      init  : null
    },

    leftHbox :
    {
      check : "Object",
      init  : null
    },

    rightHbox :
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
     * @param widget {var} TODOC
     * @return {void} 
     */
    addLeft : function(widget)
    {
      var hbox = this.getLeftHbox();

      if (hbox) {
        hbox.add(widget);
      }
    },


    /**
     * TODOC
     *
     * @param widget {var} TODOC
     * @return {void} 
     */
    addRight : function(widget)
    {
      var hbox = this.getRightHbox();

      if (hbox) {
        hbox.add(widget);
      }
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    clearIt : function()
    {
      var hbox = this.getLeftHbox();
      if (hbox) hbox.removeAll();

      hbox = this.getRightHbox();
      if (hbox) hbox.removeAll();

      this.getPart().removeAll();
    },


    /**
     * TODOC
     *
     * @param widget {var} TODOC
     * @return {void} 
     */
    addWidget : function(widget)
    {
      this.removeWidget(widget);
      var part = this.getPart();
      part.add(widget);
    },


    /**
     * TODOC
     *
     * @param widget {var} TODOC
     * @return {void} 
     */
    removeWidget : function(widget)
    {
      var part = this.getPart();
      var widgets = part.getChildren();

      widget_index = widgets.indexOf(widget);

      if (widget_index != -1) {
        part.removeAt(widget_index);
      }
    },


    /**
     * TODOC
     *
     * @param abstractWindow {var} TODOC
     * @return {var} TODOC
     */
    _createIcon : function(abstractWindow)
    {
      var title = abstractWindow.getWindowTitle();
      var icon = abstractWindow.getWindowIcon();
      var button = new qx.ui.form.Button(title, icon);

      button.addListener("execute", function()
      {
        abstractWindow.doMaximize();

        var part = this.getPart();
        var icons = part.getChildren();
        icon_index = icons.indexOf(button);
        part.removeAt(icon_index);
      },
      this);

      return button;
    },


    /**
     * TODOC
     *
     * @param abstractWindow {var} TODOC
     * @return {void} 
     */
    minimize : function(abstractWindow)
    {
      var part = this.getPart();
      var icon = this._createIcon(abstractWindow);
      part.add(icon);
    }
  }
});