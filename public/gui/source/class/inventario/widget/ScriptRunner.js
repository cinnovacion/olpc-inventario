
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
qx.Class.define("inventario.widget.ScriptRunner",
{
  extend : inventario.window.AbstractWindow,

  construct : function()
  {
    this.base(arguments, qx.locale.Manager.tr("Run Script"));
    this._comboBox = null;
    this._getList();
  },

  properties :
  {
    scriptListUrl :
    {
      check : "String",
      init  : "/script_runner/script_list"
    },

    runScriptUrl :
    {
      check : "String",
      init  : "/script_runner/run_script"
    }
  },

  members :
  {
    _createLayout : function(options)
    {
      var layout = this.getVbox();
      layout.getLayout().setSpacing(5);
      var cbWidget = new qx.ui.form.SelectBox;
      var runButton = new qx.ui.form.Button(qx.locale.Manager.tr("Run"), "inventario/16/no.png");

      inventario.widget.Form.loadComboBox(cbWidget, options, true);
      runButton.addListener("execute", this._runScript, this);

      layout.add(cbWidget);
      layout.add(runButton);

      this._comboBox = cbWidget;
    },

    _getList : function()
    {
      var hopts = {};
      hopts["url"] = this.getScriptListUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._getListCb;
      hopts["data"] = null;

      inventario.transport.Transport.callRemote(hopts, this);
    },

    _getListCb : function(remoteData, params)
    {
      var options = remoteData.options;
      this._createLayout(options);
      this.open();
    },

    _runScript : function()
    {
      var script_key = inventario.widget.Form.getInputValue(this._comboBox);
      var hopts = {};
      hopts["url"] = this.getRunScriptUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._runScriptCb;
      hopts["data"] = { script_key : script_key };

      inventario.transport.Transport.callRemote(hopts, this);
    },

    _runScriptCb : function(remoteData, params) {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);
    }
  }
});
