
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
// ApplicationLauncher.js
// Widget for simple and customized GUI.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Paraguay Educa 2009

/*
  #asset(qx/icon/Tango/22/apps/preferences-users.png)
  #asset(qx/icon/Tango/22/actions/system-search.png)
  #asset(qx/icon/Tango/22/actions/contact-new.png)
*/

qx.Class.define("inventario.widget.ApplicationLauncher",
{
  extend : qx.ui.container.Composite,

  /*
       * CONSTRUCTOR
       */

  construct : function(page)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(3));
      this._page = page;
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
    contentRequestUrl :
    {
      check : "String",
      init  : ""
    },

    menuElements :
    {
      check : "Object",
      init  : []
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
    loadGuiContent : function()
    {
      var hopts = {};
      hopts.url = this.getContentRequestUrl();
      hopts.parametros = null;
      hopts.handle = this._loadGuiContentResp;
      hopts.data = null;

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadGuiContentResp : function(remoteData, params)
    {
      this.removeAll();
      var menu = new qx.ui.menu.Menu;

      for (var i in remoteData.elements) {
        menu.add(this._loadGuiContentRespRec(remoteData.elements[i]));
      }

      this.add(new qx.ui.form.MenuButton(remoteData.label, remoteData.image, menu));
    },


    /**
     * TODOC
     *
     * @param node {Node} TODOC
     * @return {var} TODOC
     */
    _loadGuiContentRespRec : function(node)
    {
      var command = null;
      var menu = null;
      var execute = null;

      switch(node.type)
      {
        case "option":
          menu = new qx.ui.menu.Menu;

          for (var i in node.elements) {
            menu.add(this._loadGuiContentRespRec(node.elements[i]));
          }

          break;

        case "abmform":
            execute = function() {
                inventario.window.Abm2Extensions.launchAbmForm(node.label, node.options.option, this);
            };
          break;

        case "abm2":
          execute = function() {
            inventario.window.Abm2Extensions.launch(node.label, node.options, this);
          };

          break;

        case "report":
          execute = function() {
            inventario.report.ReportGeneratorExtensions.launch(node.label, node.options);
          };

          break;

        case "node_tracker":
          execute = function() {
            inventario.widget.NodeTracker.launch(this._page);
          };

          break;

        case "school_manager":
          execute = function() {
            inventario.window.SchoolManager.launch(this._page, node.options, node.label);
          };

          break;

        case "data_importer":
          execute = function() {
            inventario.widget.DataImporter.launch(this._page);
          };

          break;

        case "place_tool_box":
          execute = function() {
            inventario.widget.PlaceCreationToolBox.launch(this._page);
          };

          break;

        case "script_runner":
          execute = function() {
            inventario.widget.ScriptRunner.launch(this._page);
          };

          break;
      }

      var menuButton = new qx.ui.menu.Button(node.label, node.image, command, menu);

      if (execute != null) {
        menuButton.addListener("execute", execute, this);
        var hElement = {label : node.label, callback : execute, context : this};
        this.getMenuElements().push(hElement);
      }

      return (menuButton);
    }
  }
});
