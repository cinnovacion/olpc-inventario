
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

  /*
       * CONSTRUCTOR
       */

  construct : function(page)
  {
    this.base(arguments, page);
    this._comboBox = null;
  },

  /*
       * STATICS
       */

  statics :
  {
    /**
     * TODOC
     *
     * @param page {var} TODOC
     * @return {void} 
     */
    launch : function(page)
    {
      var scriptRunner = new inventario.widget.ScriptRunner(null);
      scriptRunner.setPage(page);
      scriptRunner.setWindowTitle("Ejecutar Script");
      scriptRunner.setUsePopup(true);
      scriptRunner.show();
    }
  },

  /*
       * PROPERTIES
       */

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

  /*
       * MEMBERS
       */

  members :
  {
    /**
     * TODOC
     *
     * @param layout {var} TODOC
     * @return {void} 
     */
    _doShow : function(layout) {
      this._doShow2(layout);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    show : function() {
      this._getList();
    },


    /**
     * TODOC
     *
     * @param options {var} TODOC
     * @return {void} 
     */
    _createLayout : function(options)
    {
      var layout = new qx.ui.container.Composite(new qx.ui.layout.VBox(5));
      var cbWidget = new qx.ui.form.SelectBox;
      var runButton = new qx.ui.form.Button("Ejecutar", "inventario/16/no.png");

      inventario.widget.Form.loadComboBox(cbWidget, options, true);
      runButton.addListener("execute", this._runScript, this);

      layout.add(cbWidget);
      layout.add(runButton);

      this._comboBox = cbWidget;
      this._doShow(layout);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _getList : function()
    {
      var hopts = {};
      hopts["url"] = this.getScriptListUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._getListCb;
      hopts["data"] = null;

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _getListCb : function(remoteData, params)
    {
      var options = remoteData.options;
      this._createLayout(options);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _runScript : function()
    {
      var script_key = inventario.widget.Form.getInputValue(this._comboBox);
      var hopts = {};
      hopts["url"] = this.getRunScriptUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._runScriptCB;
      hopts["data"] = { script_key : script_key };

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _runScriptCb : function(remoteData, params) {
      alert(remoteData.msg);
    }
  }
});