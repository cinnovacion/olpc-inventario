
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
// SchoolInfo.js
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Displays general Information about a schoool.
qx.Class.define("inventario.widget.SchoolInfo",
{
  extend : inventario.window.AbstractWindow,

  /*
       * CONSTRUCTOR
       */

  construct : function(page, school_id)
  {
    this.base(arguments, page);
    this.school_id = school_id;
  },

  /*
       * PROPERTIES
       */

  properties :
  {
    initialDataUrl :
    {
      check : "String",
      init  : "/schools/general_info"
    },

    verticalBox : { check : "Object" }
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
    show : function()
    {
      this._createLayout();
      this._loadInitialData();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _doShow : function()
    {
      var mainVBox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));
      mainVBox.add(this.getVerticalBox());

      this._doShow2(mainVBox);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _createInputs : function() {},


    /**
     * TODOC
     *
     * @return {void} 
     */
    _setHandlers : function() {},


    /**
     * TODOC
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20), { height : 700 });
      this.setVerticalBox(vbox);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _loadInitialData : function()
    {
      var hopts = {};
      hopts["url"] = this.getInitialDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadInitialDataResp;
      hopts["data"] = { id : this.school_id };

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadInitialDataResp : function(remoteData, params)
    {
      var gl = new qx.ui.layout.VBox();
      var container = new qx.ui.container.Composite(gl);

      var info = remoteData["info"];

      for (var i in info)
      {
        container.add(new qx.ui.basic.Label().set(
        {
          rich    : true,
          content : "<b>" + info[i].label.toString() + "</b>"
        }));

        container.add(new qx.ui.basic.Label(info[i].data.toString()));
      }

      this.getVerticalBox().add(container, { flex : 1 });
      this._doShow();
    }
  }
});
