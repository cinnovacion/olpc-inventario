
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
// A widget to display information of the current state of the database:
// - number of laptops pending of being revised
// - number of laptops ready to be picked up (after being revised + fixed)
//
//
// TODO: divide the views in multiple tabs according to areas (deliveries, shipments, etc.)
//
qx.Class.define("inventario.window.WelcomeInfo",
{
  extend : inventario.window.AbstractWindow,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function(page) {
    this.base(arguments, page);
  },


  /*
      *****************************************************************************
         PROPERTIES
      *****************************************************************************
      */

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




  /*
      *****************************************************************************
         MEMBERS
      *****************************************************************************
      */

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
        container.add(new qx.ui.basic.Label("Acceso rápido"));
        spotlight.setMaxWidth(200);
        spotlight.setAlignX('right');
        spotlight.setAlignY('top');
        autocomplete.setContainer(container);
        autocomplete.setAutocompleteElements(this.getMenuElements());
        autocomplete.show();
        spotlight.add(container);
        return spotlight;
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @return {var} TODOC
     */
    _oldSystemInfo : function(remoteData)
    {
      var gl = new qx.ui.layout.Grid();
      var container = new qx.ui.container.Composite(gl);
      var row = 0;
      var dict = remoteData["infoDict"];

      for (var k in dict)
      {
        var label = new qx.ui.basic.Label(k);
        var valueField = new qx.ui.form.TextField();
        valueField.setReadOnly(true);
        valueField.setValue(dict[k].toString());

        container.add(label,
        {
          row    : row,
          column : 0
        });

        container.add(valueField,
        {
          row    : row,
          column : 1
        });

        row++;
      }

      return container;
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _testCode : function()
    {
      // TODO: move to tests
      var w = new inventario.widget.DateRange();
      this.getVerticalBox().add(w);

      var v = new Array();

      v.push(
      {
        label   : "Laptop:",
        cb_name : "laptop"
      });

      v.push(
      {
        label   : "Cargador:",
        cb_name : "charger"
      });

      v.push(
      {
        label   : "Bateria:",
        cb_name : "battery"
      });

      v.push(
      {
        label   : "Cualquiera:",
        cb_name : "any"
      });

      var widget = new inventario.widget.CheckboxSelector("Partes", v);
      this.getVerticalBox().add(widget);

      var v = new Array();

      v.push(
      {
        text  : "Olimpia",
        value : 1
      });

      v.push(
      {
        text  : "Cerro",
        value : 2
      });

      var widget = new inventario.widget.ComboboxSelector("Equipo", v);
      this.getVerticalBox().add(widget);

      var v = new Array();

      v.push(
      {
        text     : "Laptop:",
        value    : "laptop",
        datatype : "textfield"
      });

      v.push(
      {
        text     : "Cargador:",
        value    : "charger",
        datatype : "textfield"
      });

      v.push(
      {
        text     : "Bateria:",
        value    : "battery",
        datatype : "textfield"
      });

      v.push(
      {
        text     : "Cualquiera:",
        value    : "any",
        datatype : "textfield"
      });

      var widget = new inventario.widget.ColumnValueSelector(v);
      this.getVerticalBox().add(widget);

      var but = new qx.ui.form.Button("Report Generator");

      but.addListener("execute", function(e)
      {
        var r = new inventario.report.ReportGenerator();
        r.setReportName("test_report_widget");
        r.setUsePopup(true);
        r.show();
      },
      this);

      this.getVerticalBox().add(but);

      var form = new uploadwidget.UploadForm('uploadFrm', '/people/test_save_file');
      form.setLayout(new qx.ui.layout.Basic);

      var file = new uploadwidget.UploadField('uploadfile', 'Examinar', 'icon/16/actions/document-save.png');

      form.add(file,
      {
        left : 0,
        top  : 0
      });

      this.getVerticalBox().add(form);

      var but = new qx.ui.form.Button("Enviar");

      but.addListener("execute", function(e)
      {
        if (file.getFieldValue() != '')
        {
          var hopts = {};
          hopts["url"] = "/people/test_save_file";
          hopts["parametros"] = null;
          hopts["handle"] = function(e) {};

          hopts["data"] =
          {
            uploadfile : file._button._input,
            hola       : "chau"
          };

          hopts["file_upload"] = true;
          hopts["file_upload_form"] = form;

          inventario.transport.Transport.callRemote(hopts, this);
        }
      },
      this);

      this.getVerticalBox().add(but);

      // widget tabla p/ AbmForm
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));

      var w = new inventario.widget.DynTable();

      var v = new Array();

      v.push(
      {
        datatype : "textfield",
        label    : "tincho"
      });

      v.push(
      {
        datatype : "textfield",
        label    : "tincho"
      });

      v.push(
      {
        datatype : "textfield",
        label    : "tincho"
      });

      v.push(
      {
        datatype : "textfield",
        label    : "tincho"
      });

      w.setColumnsData(v);

      var td = {};
      td.col_titles = [ "A", "B", "C", "D" ];
      td.widths = [ 50, 50, 50, 50 ];
      td.hashed_data = [ "a", "b", "c", "d" ];
      w.setTableDef(td);

      w.setPage(hbox);
      this.getVerticalBox().add(hbox);
      w.show();

      var but = new qx.ui.form.Button("Ver Contenido Tabla");

      but.addListener("execute", function(e)
      {
        var table_data = w.getTableData();
        alert(qx.util.Json.stringify(table_data));
      },
      this);

      this.getVerticalBox().add(but);

      var tree = new Array();
      var c1 = new Array();
      c1["name"] = "Controller 1";
      c1["methods"] = new Array();

      var m1 = new Array();
      m1["name"] = "method 1";
      m1["selected"] = true;

      var m2 = new Array();
      m2["name"] = "method 2";
      m2["selected"] = false;

      c1["methods"].push(m1);
      c1["methods"].push(m2);
      tree.push(c1);

      alert(tree[0].name);

      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      var permissions = new inventario.widget.Permissions(null, tree);
      permissions.setPage(hbox);
      this.getVerticalBox().add(hbox);
      permissions.show();

      var html = new qx.ui.embed.Html();
      html.setHtml("<script type=\"text/javascript\">alert(\"hola\");</script>");
      html.show();
      this.getVerticalBox().add(html);

      var iframe = new qx.ui.embed.Iframe();
      iframe.setSource("http://code.google.com/apis/maps/documentation/examples/marker-simple.html");
      iframe.setHeight(400);
      iframe.setWidth(400);
      iframe.show();
      this.getVerticalBox().add(iframe, { flex : 1 });

      var map_embed = new qx.ui.embed.Html();
      map_embed.setAllowGrowX(false);
      map_embed.setAllowGrowY(false);
      map_embed.setHeight(300);
      map_embed.setWidth(400);

      map_embed.addListenerOnce("appear", function(e)
      {
        if (GBrowserIsCompatible())
        {
          var dom_element = map_embed.getContentElement().getDomElement();
          var size = new GSize(400, 300);
          var uiOptions = new GMapUIOptions(size);
          var map = new GMap2(dom_element);
          map.setCenter(new GLatLng(-25.26666667, -57.666667), 15);
          map.setUI(uiOptions);
          map.openInfoWindow(map.getCenter(), document.createTextNode("Hello, world"));

          //             GEvent.addListener(map, "click", function() {
          //               map.panTo(new GLatLng(37.4569, -122.1569));
          //             });
          // map.enableGoogleBar();
          // map.enableScrollWheelZoom();
          // map.addControl(new GLargeMapControl());
          // var mgrOptions = { borderPadding: 50, maxZoom: 15, trackMarkers: true };
          // var mgr = new MarkerManager(map, mgrOptions);
          var blueIcon = new GIcon(G_DEFAULT_ICON);
          blueIcon.image = "http://www.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png";
          blueIcon.iconSize = new GSize(15, 15);
          blueIcon.shadowSize = new GSize(15, 15);
          blueIcon.iconAnchor = new GPoint(15, 15);
          blueIcon.infoWindowAnchor = new GPoint(10, 10);

          markerOptions = { icon : blueIcon };

          // Add 10 markers to the map at random locations
          var bounds = map.getBounds();
          var southWest = bounds.getSouthWest();
          var northEast = bounds.getNorthEast();
          var lngSpan = northEast.lng() - southWest.lng();
          var latSpan = northEast.lat() - southWest.lat();

          for (var i=0; i<10; i++)
          {
            var latlng = new GLatLng(southWest.lat() + latSpan * Math.random(), southWest.lng() + lngSpan * Math.random());
            map.addOverlay(new GMarker(latlng, markerOptions));
          }
        }
      },
      this);

      this.getVerticalBox().add(map_embed);

      var dataHash = {};

      dataHash.center =
      {
        "lat" : -25.26666667,
        "lng" : -57.666667
      };

      dataHash.readOnly = true;
      dataHash.zoom = 13;
      dataHash.width = 400;
      dataHash.height = 300;

      var node1 =
      {
        "name"     : "school01",
        "type"     : "ap",
        "lat"      : -25.26666967,
        "lng"      : -57.696669,
        type_value : "iconUrl1"
      };

      var node2 =
      {
        "name"     : "school02",
        "type"     : "ap",
        "lat"      : -25.29666697,
        "lng"      : -57.666669,
        type_value : "iconUrl2"
      };

      dataHash.nodes = new Array();
      dataHash.nodes.push(node1);
      dataHash.nodes.push(node2);

      var menuDesc = new Array();

      menuDesc.push(
      {
        "text"     : "ap",
        "value"    : "iconUrl1",
        "selected" : true
      });

      menuDesc.push(
      {
        "text"     : "electric",
        "value"    : "iconUrl2",
        "selected" : false
      });

      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      var mapWidget = new inventario.widget.MapLocator(null, 8, true, 400, 300, true);
      mapWidget.setPage(hbox);
      mapWidget.show();
      mapWidget.startAutoResfresh(15000);
      this.getVerticalBox().add(hbox);

      var elButton = new qx.ui.form.Button("dddd");

      elButton.addListener("execute", function(e) {
        alert(mapWidget.getValues().toString());
      });

      this.getVerticalBox().add(elButton);

      var hash = hex_sha1("hola");
      alert(hash);

      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      var dataImport = new inventario.widget.DataImporter(null);
      dataImport.setPage(hbox);
      dataImport.show();
      this.getVerticalBox().add(hbox);

      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      var dynDelForm = new inventario.widget.DynamicDeliveryForm(null);
      dynDelForm.setPage(hbox);
      dynDelForm.show();
      this.getVerticalBox().add(hbox);

      var elButton = new qx.ui.form.Button("dddd");

      elButton.addListener("execute", function(e) {
        alert(dynDelForm.getValues().toString());
      });

      this.getVerticalBox().add(elButton);
      this.getVerticalBox().add(new inventario.widget.CoordsTextField(555));
      var txt = new qx.ui.form.TextField();

      txt.addListener("input", function(e) {
        alert("salto!");
      }, this);

      this.getVerticalBox().add(txt);
      var logoutwidget = new inventario.sistema.Logout();
      this.getVerticalBox().add(logoutwidget);

      var test = new inventario.widget.MultipleChoiceFieldMaker("Preguntar tal", [
      {
        id      : 99,
        text    : "opcion1",
        checked : true
      } ]);

      var elButton = new qx.ui.form.Button("dddd");

      elButton.addListener("execute", function(e) {
        alert(test.getValues().options[1].id.toString());
      });

      this.getVerticalBox().add(test);
      this.getVerticalBox().add(elButton);

      var questions = [
      {
        id : 999,
        text : "Preguntar tal",

        options : [
        {
          id      : 99,
          text    : "opcion1",
          checked : true
        } ]
      } ];

      var test = new inventario.widget.MultipleChoiceFormMaker(questions);
      var elButton = new qx.ui.form.Button("test");

      elButton.addListener("execute", function(e)
      {
        var questions = test.getValues();
        alert(questions[0].options[0].id.toString());
      });

      this.getVerticalBox().add(test);
      this.getVerticalBox().add(elButton);
    }
  }
});
