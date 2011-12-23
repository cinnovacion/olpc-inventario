
//     Copyright Paraguay Educa 2009
//     Copyright Daniel Drake 2010
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
// DynamicDeliveryForm.js
// A simple dynamic form for creating movements in order to complete
// laptop assignation and handout.
//
// Author: Daniel Drake
qx.Class.define("inventario.widget.DynamicDeliveryForm",
{
  extend : qx.ui.container.Composite,

  construct : function(mode)
  {
    this._vbox = new qx.ui.layout.VBox(20);
    this.base(arguments, this._vbox);
    this._mode = mode;
    this._fields = null;
    this._placesCombo = null;
  },

  properties :
  {
    placesDataUrl :
    {
      check : "String",
      init  : "/places/requestPlaces"
    },

    peopleDataUrl :
    {
      check : "String",
      init  : "/people/laptopsNotInHands"
    }
  },

  members :
  {
    getValues : function()
    {
      if (this._fields == null || !this._fields.hasChildren())
        return null;

      var grid = this._fields.getChildren()[0].getLayout();
      var list = new Array();

      for (var i = 0; i < grid.getRowCount(); i++)
      {
        var checked = grid.getCellWidget(i, 1).getValue();
        var laptopSN = grid.getCellWidget(i, 2).getValue();

        if (checked != 0 && laptopSN != "")
          list.push(laptopSN);
      }

      return list;
    },

    launch : function()
    {
      var hopts = {};
      hopts["url"] = this.getPlacesDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadInitialDataRespCb;
      hopts["data"] = { sections_only : true };

      inventario.transport.Transport.callRemote(hopts, this);
    },

    _loadInitialDataRespCb : function(remoteData, params) {
      this.add(this._addPlacesCombo(remoteData.places));
      this.add(this._addForm());
    },

    _addPlacesCombo : function(places)
    {
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));

      var placesLabel = new qx.ui.basic.Label("Localidad: ");

      var placesCombo = new qx.ui.form.SelectBox;
      placesCombo.setWidth(360);
      inventario.widget.Form.loadComboBox(placesCombo, places, true);
      placesCombo.addListener("changeSelection", this._loadForm, this);

      hbox.add(placesLabel);
      hbox.add(placesCombo);
      this._placesCombo = placesCombo;

      return hbox;
    },

    _addForm : function()
    {
      var subMainVbox = new qx.ui.container.Composite(new qx.ui.layout.VBox());

      var scrollContainer = new qx.ui.container.Scroll();

      scrollContainer.set(
      {
        width  : 300,
        height : 200
      });

      subMainVbox.add(scrollContainer);

      var fields = new qx.ui.container.Composite(new qx.ui.layout.VBox());
      scrollContainer.add(fields);

      this._fields = fields;
      return subMainVbox;
    },

    _loadForm : function()
    {
      var placeId = inventario.widget.Form.getInputValue(this._placesCombo);
      var hopts = {};
      hopts["url"] = this.getPeopleDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadFormRespCb;

      hopts["data"] =
      {
        place_id   : placeId,
        mode       : this._mode
      };

      inventario.transport.Transport.callRemote(hopts, this);
    },

    _loadFormRespCb : function(remoteData, params)
    {
      this._fields.removeAll();
      var grid = new qx.ui.container.Composite(new qx.ui.layout.Grid(5, 5));
      var items = remoteData.items;

      for (var i = 0; i < items.length; i++)
      {
        var assignation = items[i];
        var cnt = i + 1;

        grid.add(new qx.ui.basic.Label(cnt.toString()),
        {
          row    : i,
          column : 0
        });

        var checkbox = new qx.ui.form.CheckBox(assignation[1]);
        checkbox.setValue(true);
        grid.add(checkbox,
        {
          row    : i,
          column : 1
        });

        grid.add(new qx.ui.basic.Label(assignation[0]),
        {
          row    : i,
          column : 2
        });
      }

      this._fields.add(grid);
    }
  }
});
