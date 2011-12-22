
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
// NodeTracker.js
// Used for checking the state of the nodes in maps + sub maps.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// 2009
qx.Class.define("inventario.widget.NodeTracker",
{
  extend : inventario.window.AbstractWindow,

  construct : function(page)
  {
    this.base(arguments, page);
    this._placesCombo = null;
    this._mapWidget = null;
    this._refreshText = null;
  },

  statics :
  {
    launch : function(page)
    {
      var nodes_state = new inventario.widget.NodeTracker(null);
      nodes_state.setPage(page);
      nodes_state.setUsePopup(true);
      nodes_state.show();
    }
  },

  properties :
  {
    initialDataUrl :
    {
      check : "String",
      init  : "/places/requestPlaces"
    },

    verticalBox : { check : "Object" }
  },

  members :
  {
    show : function() {
      this._loadInitialData();
    },

    _doShow : function(mainVBox)
    {
      this.setVerticalBox(mainVBox);
      this._doShow2(mainVBox);
      this._setWindowTitle();
    },

    _createLayout : function(places, node_types)
    {
      var mainVBox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));

      mainVBox.add(this._trackMenu(places));
      mainVBox.add(this._filtersMenu(node_types));

      var scroller = new qx.ui.container.Scroll();

      scroller.set(
      {
        width  : 500,
        height : 400
      });

      scroller.add(this._mapLocator());

      mainVBox.add(scroller);
      mainVBox.add(this._statisticsMenu());

      this._doShow(mainVBox);
    },

    _loadInitialData : function()
    {
      var hopts = {};
      hopts["url"] = this.getInitialDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadInitialDataResp;
      hopts["data"] = { nodes_only : true };

      inventario.transport.Transport.callRemote(hopts, this);
    },

    _loadInitialDataResp : function(remoteData, params) {
      this._createLayout(remoteData.places, remoteData.node_types);
    },

    _mapLocator : function()
    {
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));

      var initValue = inventario.widget.Form.getInputValue(this._placesCombo);

      var mapWidget = new inventario.widget.MapLocator(Number(initValue), true, 800, 600, true);
      hbox.add(mapWidget);
      mapWidget.launch();
      mapWidget.startAutoResfresh(Number(this._refreshText.getValue()) * 1000);

      this._mapWidget = mapWidget;
      return hbox;
    },

    _trackMenu : function(places)
    {
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));

      var placesLabel = new qx.ui.basic.Label(qx.locale.Manager.tr("Location: "));

      var placesCombo = new qx.ui.form.SelectBox;
      inventario.widget.Form.loadComboBox(placesCombo, places, true);
      placesCombo.addListener("changeSelection", this._updatePlaceId, this);

      var default_time = 60 * 2;
      var refreshLabel = new qx.ui.basic.Label(qx.locale.Manager.tr("Update on (Seconds): "));
      var refrehText = new qx.ui.form.TextField(default_time.toString());

      var resetButton = new qx.ui.form.Button("Reset");
      resetButton.addListener("execute", this._callReset, this);

      hbox.add(placesLabel);
      hbox.add(placesCombo);
      hbox.add(refreshLabel);
      hbox.add(refrehText);
      hbox.add(resetButton);
      this._placesCombo = placesCombo;
      this._refreshText = refrehText;

      return hbox;
    },

    _filtersMenu : function(node_types)
    {
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));

      for (var i in node_types)
      {
        var filter_cb = new qx.ui.form.CheckBox(node_types[i].label);
        filter_cb.setValue(node_types[i].checked);
        filter_cb.setUserData("type_id", Number(node_types[i].cb_name));
        filter_cb.addListener("changeValue", this._updateNodeTypeIds, this);

        hbox.add(filter_cb);
      }

      return hbox;
    },

    _statisticsMenu : function()
    {
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));

      var statisticsButton = new qx.ui.form.Button("Statistics");
      var statisticsLabel = new qx.ui.basic.Label().set({ rich : true });

      this._timer = new qx.event.Timer(2000);

      this._timer.addListener("interval", function()
      {
        var content = "";
        var statistics = this._mapWidget.getNodeTypeStatistics();

        for (var key in statistics) {
          content += "<U>" + key + "</U>: " + "<b>" + statistics[key].toString() + "</b>" + " ";
        }

        statisticsLabel.set({ value : content });
      },
      this);

      hbox.add(statisticsLabel);
      this._timer.start();

      return hbox;
    },

    _updateNodeTypeIds : function(e)
    {
      var filter_cb = e.getCurrentTarget();
      var type_id = filter_cb.getUserData("type_id");
      var type_ids = this._mapWidget.getNodeTypeIds();
      var index = type_ids.indexOf(type_id);

      if (!filter_cb.getValue())
      {
        if (index >= 0) {
          type_ids.splice(index, 1);
        }
      }
      else
      {
        if (index < 0) {
          type_ids.push(type_id);
        }
      }

      this._mapWidget.setNodeTypeIds(type_ids);
    },

    // this._mapWidget.forceRefresh({ center : true }); To much spam.
    _updatePlaceId : function()
    {
      var placeId = inventario.widget.Form.getInputValue(this._placesCombo);
      this._mapWidget.setPlaceId(Number(placeId));
      this._mapWidget.forceRefresh({ center : true });

      this._setWindowTitle();
    },

    _setWindowTitle : function()
    {
      var placeName = this._placesCombo.getSelection()[0].getLabel();
      this.setWindowTitle(placeName);
    },

    _callReset : function()
    {
      if (this._mapWidget != null)
      {
        this._mapWidget.resetTimer(Number(this._refreshText.getValue()) * 1000);
        this._mapWidget.forceRefresh({ center : true });
      }
    }
  }
});
