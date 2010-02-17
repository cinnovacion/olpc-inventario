
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
// MapLocator.js
// Implementation of Google Map API.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Paraguay Educa 2009
qx.Class.define("inventario.widget.MapLocator",
{
  extend : inventario.window.AbstractWindow,

  /*
       * CONSTRUCTOR
       */

  construct : function(page, placeId, readOnly, width, height, subNodes)
  {
    this.base(arguments, page);

    // State variables
    this._readOnly = readOnly;
    this.setPlaceId(placeId);
    this.setWidth(width);
    this.setHeight(height);

    // TODO : Find the proper way to access the markers inner structure.
    this._markers = new Array();

    // Google Map objects.
    this._map = null;
    this._selectedNode = null;

    // Qooxdoo Objects for Edit menu.
    this._typeCombo = null;
    this._nodeText = null;
    this._latText = null;
    this._lngText = null;
    this._heightText = null;
    this._ipText = null;

    // Stuff needed for the auto-resfresh thing.
    this._timer = null;

    // Incase we are tracking also the sub map nodes.
    this._subNodes = subNodes;
  },

  /*
       * PROPERTIES
       */

  properties :
  {
    // for data request methods.
    initialDataUrl :
    {
      check : "String",
      init  : "/places/requestMap"
    },

    refreshDataUrl :
    {
      check : "String",
      init  : "/places/requestNodes"
    },

    updateDataUrl :
    {
      check : "String",
      init  : "/nodes/updateNode"
    },

    googleKeyUrl :
    {
      check : "String",
      init  : "/default_values/requestKeys"
    },

    googleApiUrl :
    {
      check : "String",
      init  : ""
    },

    placeId :
    {
      check : "Number",
      init  : -1
    },

    nodeTypeIds :
    {
      check : "Array",
      init  : []
    },

    width :
    {
      check : "Number",
      init  : 320
    },

    height :
    {
      check : "Number",
      init  : 120
    },

    // Qooxdoo Objects.
    verticalBox :
    {
      check    : "Object",
      nullable : true,
      init     : null
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
    show : function() {
      this._loadGoogleApi();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _loadGoogleApi : function()
    {
      var hopts = {};
      var data = [ "google_api_url", "google_api_key" ];

      hopts["url"] = this.getGoogleKeyUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadGoogleApiResp;
      hopts["data"] = { data : qx.util.Json.stringify(data) };

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadGoogleApiResp : function(remoteData, params)
    {
      var key = remoteData.values.google_api_key != null ? remoteData.values.google_api_key : "";
      var url = remoteData.values.google_api_url != null ? remoteData.values.google_api_url : "";
      this.setGoogleApiUrl(url + key);
      this._insertGoogleApi();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _insertGoogleApi : function()
    {
      var loader = new qx.io.ScriptLoader();
      loader.load(this.getGoogleApiUrl(), this._insertGoogleApiResp, this);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _insertGoogleApiResp : function()
    {
      var that = this;

      google.load("maps", "2",
      {
        "callback" : function() {
          that._loadInitialData.call(that);
        }
      });
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _loadInitialData : function()
    {
      var data = {};
      data.id = this.getPlaceId();

      if (this._readOnly && this._subNodes) {
        data.subNodes = this._subNodes;
      }

      var hopts = {};
      hopts["url"] = this.getInitialDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadInitialDataResp;
      hopts["data"] = data;

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
      var mapDesc = remoteData.map;
      var nodeTypes = remoteData.types;

      var type_ids_list = [];

      for (var i in nodeTypes) {
        type_ids_list.push(Number(nodeTypes[i].value));
      }

      this.setNodeTypeIds(type_ids_list);

      this._createLayout(mapDesc, nodeTypes);
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    getValues : function()
    {
      var markers = this._markers;
      var mLen = markers.length;
      var result = new Array();

      for (var i=0; i<mLen; i++) {
        result.push(this._marker2Node(markers[i]));
      }

      return result;
    },


    /**
     * TODOC
     *
     * @param marker {var} TODOC
     * @return {Node} TODOC
     */
    _marker2Node : function(marker)
    {
      var node = {};
      node.id = marker.id;
      node.name = marker.getTitle();
      node.lat = marker.getLatLng().lat();
      node.lng = marker.getLatLng().lng();
      node.height = marker.height;
      node.type = marker.value;
      node.zoom = marker.zoom;
      node.ip_address = marker.ip_address;
      return node;
    },


    /**
     * TODOC
     *
     * @param vbox {var} TODOC
     * @return {void} 
     */
    _doShow : function(vbox)
    {
      this.setVerticalBox(vbox);
      this._doShow2(vbox);
    },


    /**
     * TODOC
     *
     * @param mapDesc {var} TODOC
     * @param nodeTypes {var} TODOC
     * @return {void} 
     */
    _createLayout : function(mapDesc, nodeTypes)
    {
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      hbox.addListener("disappear", this._stopAutoResfresh, this);

      hbox.add(this._createMap(mapDesc));

      if (!this._readOnly) {
        hbox.add(this._createEditMenu(nodeTypes));
      }

      this._doShow(hbox);
    },


    /**
     * TODOC
     *
     * @param mapDesc {var} TODOC
     * @return {var} TODOC
     */
    _createMap : function(mapDesc)
    {
      var width = this.getWidth();
      var height = this.getHeight();
      var map_embed = new qx.ui.embed.Html();
      map_embed.setAllowGrowX(false);
      map_embed.setAllowGrowY(false);
      map_embed.setWidth(width);
      map_embed.setHeight(height);

      map_embed.addListenerOnce("appear", function(e)
      {
        if (GBrowserIsCompatible())
        {
          var dom_element = map_embed.getContentElement().getDomElement();
          var size = new GSize(width, height);
          var uiOptions = new GMapUIOptions(size);
          var map = new GMap2(dom_element);
          map.setCenter(new GLatLng(mapDesc.center.lat, mapDesc.center.lng), mapDesc.zoom);
          map.setUI(uiOptions);
          map.setMapType(G_HYBRID_MAP);
          this._map = map;

          nLen = mapDesc.nodes.length;

          for (var i=0; i<nLen; i++) {
            map.addOverlay(this._createMarker(mapDesc.nodes[i]));
          }

          if (!this._readOnly)
          {
            var that = this;

            GEvent.addListener(map, "click", function(overlay, latlng)
            {
              if (latlng)
              {
                that._nodeText.setValue("");
                that._latText.setValue(latlng.lat().toString());
                that._lngText.setValue(latlng.lng().toString());
                that._heightText.setValue("");
                that._ipText.setValue("");
                that._selectedNode = null;
              }
            });
          }
        }
      },
      this);

      return map_embed;
    },


    /**
     * TODOC
     *
     * @param node {Node} TODOC
     * @return {var} TODOC
     */
    _createMarker : function(node)
    {
      var point = new GLatLng(node.lat, node.lng);

      var markerOptions =
      {
        icon  : this._createIcon(node.icon),
        title : node.name
      };

      if (!this._readOnly) {
        markerOptions.draggable = true;
      }

      var marker = new GMarker(point, markerOptions);
      var html = "<b>" + node.type + "</b>: " + node.name + "<br/> ";

      for (var key in node.hashed_data) {
        html += "<b>" + key + ":</b> " + node.hashed_data[key] + "<br/>";
      }

      marker.value = node.type_value;
      marker.zoom = node.zoom;
      marker.height = node.height;
      marker.ip_address = node.ip_address;
      marker.id = node.id;
      marker.type = node.type;

      var that = this;

      GEvent.addListener(marker, 'click', function()
      {
        that._map.setZoom(marker.zoom);
        marker.openInfoWindowHtml(html);

        if (!that._readOnly)
        {
          that._nodeText.setValue(marker.getTitle());
          var latLng = marker.getLatLng();
          that._latText.setValue(latLng.lat().toString());
          that._lngText.setValue(latLng.lng().toString());
          that._heightText.setValue(marker.height);
          that._ipText.setValue(marker.ip_address);

          var cb = that._typeCombo;
          var val = marker.value;
          inventario.widget.Form.setComboBox(cb, val);

          that._selectedNode = marker;
        }
      });

      if (!this._readOnly)
      {
        GEvent.addListener(marker, "dragstart", function() {
          that._map.closeInfoWindow();
        });

        // if (that._selectedNode == null) {
        //  alert("Primer debe seleccionar el nodo antes de modificar tu posicion.");
        // }
        GEvent.addListener(marker, "dragend", function()
        {
          var point = marker.getPoint();
          that._map.panTo(point);

          that._latText.setValue(point.lat().toFixed(5).toString());
          that._lngText.setValue(point.lng().toFixed(5).toString());
        });
      }

      // TODO : Find the proper way to access to all the markers?
      this._markers.push(marker);

      return marker;
    },


    /**
     * TODOC
     *
     * @param icon {var} TODOC
     * @return {var} TODOC
     */
    _createIcon : function(icon)
    {
      var customIcon = new GIcon();

      // customIcon.image = 'http://labs.google.com/ridefinder/images/mm_20_blue.png';
      customIcon.image = icon;

      // customIcon.shadow = 'http://labs.google.com/ridefinder/images/mm_20_shadow.png';
      customIcon.iconSize = new GSize(20, 20);
      customIcon.shadowSize = new GSize(22, 22);
      customIcon.iconAnchor = new GPoint(6, 20);
      customIcon.infoWindowAnchor = new GPoint(5, 1);

      return customIcon;
    },


    /**
     * TODOC
     *
     * @param nodeTypes {var} TODOC
     * @return {var} TODOC
     */
    _createEditMenu : function(nodeTypes)
    {
      var container = new qx.ui.container.Composite(new qx.ui.layout.Grid());

      var typeLabel = new qx.ui.basic.Label("Tipo:");
      var typeCombo = new qx.ui.form.SelectBox;
      inventario.widget.Form.loadComboBox(typeCombo, nodeTypes, true);

      var nodeLabel = new qx.ui.basic.Label("Nodo:");
      var nodeText = new qx.ui.form.TextField();

      var latLabel = new qx.ui.basic.Label("Latitud:");
      var latText = new qx.ui.form.TextField();

      var lngLabel = new qx.ui.basic.Label("Longitud");
      var lngText = new qx.ui.form.TextField();

      var heightLabel = new qx.ui.basic.Label("Altura");
      var heightText = new qx.ui.form.TextField();

      var ipLabel = new qx.ui.basic.Label("Direccion Ip");
      var ipText = new qx.ui.form.TextField();

      var addButton = new qx.ui.form.Button("Agregar Nodo");

      addButton.addListener("execute", function(e)
      {
        var map = this._map;
        var node = this._form2Node(false);

        var marker = this._createMarker(node);
        map.addOverlay(marker);
        this._selectedNode = marker;
      },
      this);

      var delButton = new qx.ui.form.Button("Borrar Nodo");

      delButton.addListener("execute", function(e)
      {
        var map = this._map;
        var marker = this._selectedNode;
        this._removeMarker(marker);
      },
      this);

      var updateButton = new qx.ui.form.Button("Actualizar");

      updateButton.addListener("execute", function(e)
      {
        var marker = this._selectedNode;

        if (marker != null)
        {
          var node = this._form2Node(true);
          node.id = marker.id;

          if (node.id != -1 && node.id != null)
          {
            this._removeMarker(marker);
            this._updateNodeData(node);
          }
          else
          {
            alert("No puede actualizar un nodo recien creado.");
          }
        }
        else
        {
          alert("Nada que actualizar.");
        }
      },
      this);

      // We give private global access to these widgets.
      this._typeCombo = typeCombo;
      this._nodeText = nodeText;
      this._latText = latText;
      this._lngText = lngText;
      this._heightText = heightText;
      this._ipText = ipText;

      // We add them to the vbox.
      container.add(typeLabel,
      {
        row    : 0,
        column : 0
      });

      container.add(typeCombo,
      {
        row    : 0,
        column : 1
      });

      container.add(nodeLabel,
      {
        row    : 1,
        column : 0
      });

      container.add(nodeText,
      {
        row    : 1,
        column : 1
      });

      container.add(latLabel,
      {
        row    : 2,
        column : 0
      });

      container.add(latText,
      {
        row    : 2,
        column : 1
      });

      container.add(lngLabel,
      {
        row    : 3,
        column : 0
      });

      container.add(lngText,
      {
        row    : 3,
        column : 1
      });

      container.add(heightLabel,
      {
        row    : 4,
        column : 0
      });

      container.add(heightText,
      {
        row    : 4,
        column : 1
      });

      container.add(ipLabel,
      {
        row    : 5,
        column : 0
      });

      container.add(ipText,
      {
        row    : 5,
        column : 1
      });

      container.add(addButton,
      {
        row    : 6,
        column : 0
      });

      container.add(delButton,
      {
        row    : 6,
        column : 1
      });

      container.add(updateButton,
      {
        row    : 6,
        column : 2
      });

      return container;
    },


    /**
     * TODOC
     *
     * @param updating {var} TODOC
     * @return {Node} TODOC
     */
    _form2Node : function(updating)
    {
      var node = {};

      node.name = this._nodeText.getValue();
      node.lat = this._latText.getValue();
      node.lng = this._lngText.getValue();
      node.height = this._heightText.getValue();
      node.zoom = this._map.getZoom();
      node.ip_address = this._ipText.getValue();

      var cb = this._typeCombo;
      node.type = inventario.widget.Form.getInputValue(cb);

      if (!updating)
      {
        node.id = -1;
        //node.icon = cb.getChildrenContainer().getSelectedItem().getUserData("icon");
        node.icon = cb.getSelection()[0].getUserData("icon");

        node.type_value = node.type;
        node.type = cb.getSelection()[0].getLabel();
      }

      return node;
    },


    /**
     * TODOC
     *
     * @param marker {var} TODOC
     * @return {void} 
     */
    _removeMarker : function(marker)
    {
      // TODO: Find out how to do this correctly.
      var index = this._markers.indexOf(marker);
      this._markers.splice(index, 1);
      this._map.removeOverlay(marker);
    },


    /**
     * TODOC
     *
     * @param node {Node} TODOC
     * @return {void} 
     */
    _updateNodeData : function(node)
    {
      var data = {};
      data.node = qx.util.Json.stringify(node);

      var hopts = {};
      hopts["url"] = this.getUpdateDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._updateNodeDataResp;
      hopts["data"] = data;

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _updateNodeDataResp : function(remoteData, params)
    {
      var node = remoteData.node;
      this._map.addOverlay(this._createMarker(node));
      alert("El nodo " + node.name + " ha sido actualizado.");
    },

    // These functions are necesary for auto-refresh mode.
    /**
     * TODOC
     *
     * @param time {var} TODOC
     * @return {void} 
     */
    startAutoResfresh : function(time)
    {
      if (this._readOnly && this._timer == null && this.getPlaceId() != null)
      {
        this._timer = new qx.event.Timer(time);

        this._timer.addListener("interval", function() {
          this._refreshMap({ center : false });
        }, this);

        this._timer.start();
      }
      else
      {
        alert("Auto-refresh requires read-only mode.");
      }
    },


    /**
     * TODOC
     *
     * @param time {var} TODOC
     * @return {void} 
     */
    resetTimer : function(time)
    {
      if (this._timer != null)
      {
        if (time >= 10000) {
          this._timer.restartWith(time);
        } else {
          alert("El tiempo minimo de actualizacion de 10 segundos.");
        }
      }
    },


    /**
     * TODOC
     *
     * @param options {var} TODOC
     * @return {void} 
     */
    forceRefresh : function(options)
    {
      if (this._readOnly && this._subNodes) {
        this._refreshMap(options);
      }
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _stopAutoResfresh : function()
    {
      if (this._timer != null) {
        this._timer.stop();
      }
    },

    // alert("Stoped");
    /**
     * TODOC
     *
     * @param options {var} TODOC
     * @return {void} 
     */
    _refreshMap : function(options)
    {
      var data = {};
      data.id = this.getPlaceId();
      data.nodeTypeIds = qx.util.Json.stringify(this.getNodeTypeIds());
      data.subNodes = this._subNodes;

      var hopts = {};
      hopts["url"] = this.getRefreshDataUrl();
      hopts["parametros"] = options;
      hopts["handle"] = this._refreshMapResp;
      hopts["data"] = data;

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _refreshMapResp : function(remoteData, params)
    {
      var nodes = remoteData.nodes;
      var map = this._map;

      this._markers = new Array();
      map.clearOverlays();

      var nLen = nodes.length;

      for (var i=0; i<nLen; i++) {
        map.addOverlay(this._createMarker(nodes[i]));
      }

      if (params.center)
      {
        var center = this._findCenter();

        if (center != null) {
          this._goToMarker(center);
        }
      }
    },

    // alert("updated!");
    /**
     * TODOC
     *
     * @return {var | null} TODOC
     */
    _findCenter : function()
    {
      var markers = this._markers;
      var mLen = markers.length;

      // alert(mLen.toString());
      for (var i=0; i<mLen; i++)
      {
        // alert(markers[i].type);
        if (markers[i].type == "Centro") {
          return (markers[i]);
        }
      }

      return null;
    },


    /**
     * TODOC
     *
     * @param marker {var} TODOC
     * @return {boolean} TODOC
     */
    _goToMarker : function(marker)
    {
      var map = this._map;
      map.setZoom(marker.zoom);
      map.panTo(marker.getLatLng());
      return true;
    },

    // More and more extensions ;/
    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    getNodeTypeStatistics : function()
    {
      var statistics = {};
      var markers = this._markers;

      for (var i in markers)
      {
        if (typeof statistics[markers[i].type] == "undefined") {
          statistics[markers[i].type] = 1;
        } else {
          statistics[markers[i].type]++;
        }
      }

      return statistics;
    }
  }
});