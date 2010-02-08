
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
qx.Class.define("inventario.window.ExampleWindow",
{
  extend : inventario.window.AbstractWindow,

  /*
       * CONSTRUCTOR
       */

  construct : function(page) {
    this.base(arguments, page);
  },

  /*
       * PROPERTIES
       */

  properties :
  {
    initialDataUrl :
    {
      check : "String",
      init  : ""
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
    show : function() {},


    /**
     * TODOC
     *
     * @return {void} 
     */
    _doShow : function() {
      this._doShow2(this.getVerticalBox());
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
    _createLayout : function() {},


    /**
     * TODOC
     *
     * @return {void} 
     */
    _loadInitialData : function() {},


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadInitialDataResp : function(remoteData, params) {}
  }
});
