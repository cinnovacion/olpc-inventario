
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
// LocationFiltered.js
// ComboBox widget that acts as a normal CB but can be filtered by the information from a second CB.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Paraguay Educa 2009
qx.Class.define("inventario.widget.ComboBoxFiltered",
{
  extend : qx.ui.container.Composite,

  /*
       * CONSTRUCTOR
       */

  construct : function(cb_label, cbs_options, width)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(20));

      // We create all the layouts.
      var gl = new qx.ui.container.Composite(new qx.ui.layout.Grid());
      this._grid_layout = gl;
      this.add(gl);

      // title
      gl.add(new qx.ui.basic.Label(cb_label),
      {
        row    : 0,
        column : 0
      });

      // Combos boxes
      var filterCb = new inventario.widget.ComboboxSelector("Filtro  ", cbs_options.filter, width);

      gl.add(filterCb,
      {
        row    : 1,
        column : 0
      });

      var dataCb = new inventario.widget.ComboboxSelector("Datos", cbs_options.data, width);

      gl.add(dataCb,
      {
        row    : 2,
        column : 0
      });

      filterCb.getComboBox().addListener("changeValue", this._loadDataComboBox, this);

      this.setFilterComboBox(filterCb);
      this.setDataComboBox(dataCb);
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
    FilterComboBox : { check : "Object" },
    DataComboBox : { check : "Object" },

    dataRequestUrl :
    {
      check : "String",
      init  : ""
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
     * @return {var} TODOC
     */
    getSelectedValue : function() {
      return this.getDataComboBox().getSelectedValue();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _loadDataComboBox : function()
    {
      refValue = this.getFilterComboBox().getSelectedValue();

      var hopts = {};
      hopts["url"] = this.getDataRequestUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadDataComboBoxResp;
      hopts["data"] = { refValue : refValue };

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadDataComboBoxResp : function(remoteData, params)
    {
      var cb_options = remoteData.cb_options;
      var cb_widget = this.getDataComboBox().getComboBox();
      inventario.widget.Form.loadComboBox(cb_widget, cb_options, true);
    }
  }
});