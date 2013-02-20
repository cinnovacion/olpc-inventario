//   Copyright: Paraguay Educa 2008//     This program is free software: you can redistribute it and/or modify
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


//   License: GPL
//   Authors: Raul Gutierrez S. (lots of ideas from Sebastian Codas)

/*************************************************************************
 #asset(inventario/*)
************************************************************************ */


qx.Class.define("inventario.Application",
{
  extend : qx.application.Standalone,

  properties :
  {
    userName :
    {
      check : "String",
      init  : ""
    },

    taskBar :
    {
      check : "Object",
      init : null
    }
  },

  statics : { appInstance : null },

  members :
  {
    /**
     * This method contains the initial application code and gets called 
     * during startup of the application
     *
     * @return {void} 
     */
    main : function()
    {
      // for future references... HACK!
      inventario.Application.appInstance = this;

      // Call super class
      this.base(arguments);

      // Transtation language
      qx.locale.Manager.getInstance().setLocale("es");
      this.startApp();
    },

    startApp : function()
    {
      this.option_name = null;
      this.object_table = {};

      // clean up visual environment
      inventario.widget.Layout.removeChilds(this.getRoot());

      // Enable logging in debug variant
      if (qx.core.Environment.get("qx.debug"))
      {
        // support native logging capabilities, e.g. Firebug for Firefox
        qx.log.appender.Native;

        // support additional cross-browser console. Press F7 to toggle visibility
        qx.log.appender.Console;
      }

      var loginObj = this._getLoginObj();
      loginObj.login();
    },

    _getLoginObj : function()
    {
      // TODO: we could save a reference to this object to avoid re-instantiating
      var loginObj = new inventario.sistema.Login("/sistema/login");
      loginObj.setCallBackFn(this._loadMainWin);
      loginObj.setCallBackContext(this);

      return loginObj;
    },

    _loadMainWin : function()
    {
      // Main Vbox, containing the taskbar and the old screen.
      var mainVbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(5));
      mainVbox.setBackgroundColor('#FFFFFF');

      // Main toolbar that will act as a taskbar.
      var taskbar = new inventario.widget.TaskBar();
      this.setTaskBar(taskbar);

      var launcher = new inventario.widget.ApplicationLauncher();
      launcher.setContentRequestUrl("/sistema/gui_content");
      launcher.loadGuiContent();
      taskbar.addLeft(launcher);

      var logout = new inventario.sistema.Logout();
      taskbar.addRight(logout);

      var layout = new qx.ui.layout.VBox();
      var panel = new qx.ui.container.Composite(layout);
      this.main_panel = panel;

      var welcomeInfo = new inventario.window.WelcomeInfo();
      // pass along the list of menu elements for spotlight widget to make use of them
      welcomeInfo.setMenuElements(launcher.getMenuElements());
      panel.add(welcomeInfo);

      mainVbox.add(panel, { flex : 1 });
      mainVbox.add(taskbar);

      this.getRoot().add(mainVbox,
      {
        left   : 0,
        right  : 0,
        top    : 0,
        bottom : 0
      });
    }
  }
});
