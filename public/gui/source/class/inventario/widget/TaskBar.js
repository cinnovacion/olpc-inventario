
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

  construct : function()
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(20));

      var toolBar = new qx.ui.toolbar.ToolBar();

      var leftPart = new qx.ui.toolbar.Part();
      var part = new qx.ui.toolbar.Part();
      var rightPart = new qx.ui.toolbar.Part();

      toolBar.add(leftPart, { flex : 0 });
      toolBar.add(part, { flex : 20 });
      toolBar.add(rightPart, { flex : 0 });

      this.add(toolBar, { flex : 1 });

      this.setToolBar(toolBar);
      this.setLeftPart(leftPart);
      this.setPart(part);
      this.setRightPart(rightPart);
    }
    catch(e)
    {
      alert("Constructor: " + e.toString());
    }
  },

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

    leftPart :
    {
      check : "Object",
      init  : null
    },

    rightPart :
    {
      check : "Object",
      init  : null
    }
  },

  members :
  {
    addLeft : function(widget)
    {
      var part = this.getLeftPart();

      if (part) {
        part.add(widget);
      }
    },

    addRight : function(widget)
    {
      var part = this.getRightPart();

      if (part) {
        part.add(widget);
      }
    },

    clearIt : function()
    {
      var part = this.getLeftPart();
      if (part) {
        part.removeAll();
      }

      part = this.getRightPart();
      if (part) {
        part.removeAll();
      }

      this.getPart().removeAll();
    },

    addWidget : function(widget)
    {
      this.removeWidget(widget);
      var part = this.getPart();
      part.add(widget);
    },

    removeWidget : function(widget)
    {
      var part = this.getPart();
      var widgets = part.getChildren();
      var widget_index = widgets.indexOf(widget);

      if (widget_index != -1) {
        part.removeAt(widget_index);
      }
    },

    _createIcon : function(abstractWindow)
    {
      var title = abstractWindow.getCaption();
      var icon = abstractWindow.getIcon();
      var button = new qx.ui.form.Button(title, icon);

      button.addListener("execute", function()
      {
        abstractWindow.restore();

        var part = this.getPart();
        var icons = part.getChildren();
        var icon_index = icons.indexOf(button);
        part.removeAt(icon_index);
      },
      this);

      return button;
    },

    minimize : function(abstractWindow)
    {
      var part = this.getPart();
      var icon = this._createIcon(abstractWindow);
      part.add(icon);
    }
  }
});
