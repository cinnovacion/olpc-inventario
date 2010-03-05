
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
// WelcomeInfo.js
//
// date: 2008-12-28
// author: Raul Gutierrez S.
//
//
qx.Class.define("inventario.window.WelcomeInfo",
{
  extend : inventario.window.AbstractWindow,

  construct : function(page) {
    this.base(arguments, page);
  },

  properties :
  {
    initialDataUrl :
    {
      check : "String",
      init  : "/sistema/welcome_info"
    },

    verticalBox : { check : "Object" },

    defaultLogoPath :
    {
      check : "String",
      init  : "/images/view_by_name/logo_pyeduca.jpg"
    },

    menuElements :
    {
      check : "Object",
      init  : []
    }

  },

  members :
  {
    /**
     * show():
     *
     * @return {void} void
     */
    show : function()
    {
      this._createInputs();
      this._setHandlers();
      this._createLayout();
      this._loadInitialData();
    },


    /**
     * _doShow()
     *
     * @return {void} void
     */
    _doShow : function()
    {
      var mainVBox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));
      mainVBox.add(this.getVerticalBox());

      this._doShow2(mainVBox);
    },


    /**
     * createInputs():
     *
     * @return {void} 
     */
    _createInputs : function() {},


    /**
     * setHandlers():
     *
     * @return {void} 
     */
    _setHandlers : function() {},


    /**
     * createLayout(): metodo abstracto
     * 
     * Posicionamiento de inputs
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20), { height : 700 });
      this.setVerticalBox(vbox);
    },


    /**
     * loadInitialData():
     *
     * @return {void} 
     */
    _loadInitialData : function()
    {
      var hopts = {};
      hopts["url"] = this.getInitialDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadInitialDataResp;
      hopts["data"] = {};

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * _loadInitialDataResp():
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadInitialDataResp : function(remoteData, params)
    {
      var hbox   = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      var spacer = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      var img    = new qx.ui.basic.Image(this.getDefaultLogoPath());

      hbox.setBackgroundColor('#FFFFFF');
      hbox.add(img, { flex : 1 });
      hbox.add(spacer, { flex : 2});
      hbox.add(this.spotlight(), { flex : 1 });
      
      this.getVerticalBox().add(hbox, {flex:1});

      var hbox   = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      this.getVerticalBox().add(hbox, {flex: 1});

      // BROKEN;
      // var scope = inventario.window.Abm2SetScope.getInstance();
      // scope.show(this.getPage(), "Set scope");
      
      this._doShow();
    },


    // Perhaps we should check if menu elements was given to us in order 
    // to instantiate Autocomplete?
    spotlight : function() {
        var autocomplete = new inventario.widget.Autocomplete();
        var spotlight    = new qx.ui.container.Stack();
        var container    = new qx.ui.container.Composite(new qx.ui.layout.VBox(5));
        container.add(new qx.ui.basic.Label(qx.locale.Manager.tr("Quick access")));
        spotlight.setMaxWidth(200);
        spotlight.setAlignX('right');
        spotlight.setAlignY('top');
        autocomplete.setContainer(container);
        autocomplete.setAutocompleteElements(this.getMenuElements());
        autocomplete.show();
        spotlight.add(container);
        return spotlight;
    }

  }
});
