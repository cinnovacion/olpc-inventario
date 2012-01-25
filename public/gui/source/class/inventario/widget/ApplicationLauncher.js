
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

  construct : function()
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(3));
    }
    catch(e)
    {
      alert(e.toString());
    }
  },

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

  members :
  {
    loadGuiContent : function()
    {
      var hopts = {};
      hopts.url = this.getContentRequestUrl();
      hopts.parametros = null;
      hopts.handle = this._loadGuiContentResp;
      hopts.data = null;

      inventario.transport.Transport.callRemote(hopts, this);
    },

    _loadGuiContentResp : function(remoteData, params)
    {
      this.removeAll();
      var menu = new qx.ui.menu.Menu;

      for (var i in remoteData.elements) {
        menu.add(this._loadGuiContentRespRec(remoteData.elements[i]));
      }

      this.add(new qx.ui.form.MenuButton(remoteData.label, remoteData.image, menu));
    },

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
              var options = inventario.widget.Url.getUrl(node.options.option);
              var form = new inventario.window.AbmForm(options.addUrl, options.saveUrl);
              form.launch();
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

        case "barcode_report":
          execute = function() {
            new inventario.window.BarcodeReport().open();
          };
          break;

        case "node_tracker":
          execute = function() {
            new inventario.widget.NodeTracker().launch();
          };

          break;

        case "data_importer":
          execute = function() {
            new inventario.widget.DataImporter().launch();
          };

          break;

        case "place_tool_box":
          execute = function() {
            new inventario.widget.PlaceCreationToolBox().open();
          };

          break;

        case "script_runner":
          execute = function() {
            new inventario.widget.ScriptRunner();
          };

          break;

        case "people_mover":
          execute = function() {
            new inventario.widget.PeopleMover().open();
          };

          break;

        case "barcode_scan":
          execute = function() {
            new inventario.window.BarcodeScanForm(node.options["mode"]).open();
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
