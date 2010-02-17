
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
// Logout.js
// A logout widget for the taskbar.
// Author: Martin Abente - ( tincho_02@hotmail.com | mabente@paraguayeduca.org )
// Paraguay Educa 2009
qx.Class.define("inventario.sistema.Logout",
{
  type : "singleton",
  extend : qx.ui.container.Composite,

  /*
  * CONSTRUCTOR
  */

  /*
    #asset(qx/icon/Tango/22/actions/application-exit.png)
  */
  construct : function()
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(20));

      // We create all the layouts.
      var mainHbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      this.add(mainHbox);

      var logoutButton = new qx.ui.form.Button("Logout", "qx/icon/Tango/22/actions/application-exit.png");
      logoutButton.addListener("execute", this._doLogout, this);
      mainHbox.add(logoutButton);
      this.setLogoutButton(logoutButton);
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
    logoutButton :
    {
      check : "Object",
      init  : null
    },

    logoutRequestUrl :
    {
      check : "String",
      init  : "/sistema/logout"
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
     * @return {void} 
     */
    _doLogout : function()
    {
      if (confirm("Desea salir del sistema?"))
      {
        var hopts = {};
        hopts["url"] = this.getLogoutRequestUrl();
        hopts["parametros"] = null;
        hopts["handle"] = this._doLogoutResp;
        hopts["data"] = null;

        inventario.transport.Transport.callRemote(hopts, this);
      }
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _doLogoutResp : function(remoteData, params)
    {
      var message = remoteData.msg;
      inventario.Application.appInstance.startApp();
    }
  }
});

// var callback = function() { inventario.Application.appInstance.startApp(); };
// inventario.window.Mensaje.mensaje(message, callback);
