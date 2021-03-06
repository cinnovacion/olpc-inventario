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
  extend : qx.ui.window.Window,

  construct : function(title, icon, width, height)
  {
    if (title == undefined)
      title = "";
    if (icon == undefined)
      icon = "icon/22/actions/document-new.png";

    this.base(arguments, title, icon);

    if (height != undefined)
      this.setMinHeight(height);
    if (width != undefined)
      this.setMinWidth(width)

    this.addListenerOnce("appear", function(e) {
      this.center();
    });

    /*
     * Windows do not get destroyed (by default) upon close by qooxdoo.
     * With many multiple-instance windows we do want to destroy most
     * instances.
     * Users of this code can opt-out of automatic destroy-on-close with
     * the destroyOnClose property, however they must then be sure to destroy
     * the window when it is no longer needed.
     * Additionally, if a user creates a window but it is never opened,
     * the calling code must take care of destroying it.
     */
    this.addListenerOnce("close", function(e) {
      if (this.getDestroyOnClose())
        this.destroy();
    }, this);

    this.setLayout(new qx.ui.layout.VBox(10));
    this.setShowClose(true);
    this.setShowMaximize(false);

    var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));
    this.setVbox(vbox);
    this.add(vbox);
  },

  properties :
  {
    vbox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },
    destroyOnClose :
    {
      check    : "Boolean",
      init     : true
    }
  }
});
