
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
// ReportGenerator.js
//
// date: 2009-01-30
// author: Raul Gutierrez S.
//
//
// A widget to extract report of articles being moved..
//
qx.Class.define("inventario.report.ReportGenerator",
{
  extend : inventario.window.AbstractWindow,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function(page)
  {
    this.base(arguments, page);
    this._prepared = false;
    this.setWidgetArray(new Array());
    this.setDataTypes(new Array());
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
      init  : "/reports/"
    },

    verticalBox : { check : "Object" },

    generateButton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    widgetArray :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    reportName :
    {
      check : "String",
      init  : ""
    },

    reportTitle :
    {
      check : "String",
      init  : "Reporte"
    },

    printMethod :
    {
      check : "String",
      init  : ""
    },

    dataTypes :
    {
      check    : "Object",
      init     : null,
      nullable : true
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
     * @param report_name {var} TODOC
     * @param report_title {var} TODOC
     * @param use_popup {var} TODOC
     * @return {void} void
     */
    show : function(report_name, report_title, use_popup)
    {
      if (report_name) {
        this.setReportName(report_name);
      }

      if (report_title) {
        this.setReportTitle(report_title);
      }

      if (use_popup) {
        this.setUsePopup(true);
      }

      if (this.getReportName() == "")
      {
        alert("Necesito saber que reporte queres generar!");
        return;
      }

      this._createInputs();
      this._setHandlers();
      this._loadInitialData();
    },


    /**
     * _doShow()
     *
     * @return {void} void
     */
    _doShow : function()
    {
      this.setWindowTitle(this.getReportTitle());
      this._doShow2(this.getVerticalBox());
    },


    /**
     * createInputs():
     *
     * @return {void} 
     */
    _createInputs : function()
    {
      var b = new qx.ui.form.Button("Generar", "inventario/22/adobe-reader.png");
      this.setGenerateButton(b);
    },


    /**
     * setHandlers():
     *
     * @return {void} 
     */
    _setHandlers : function() {
      this.getGenerateButton().addListener("execute", this._generate_cb, this);
    },


    /**
     * createLayout(): metodo abstracto
     * 
     * Posicionamiento de inputs
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20), { height : 200 });
      this.setVerticalBox(vbox);

      // add widgets
      var v = this.getWidgetArray();

      for (var k in v) {
        this.getVerticalBox().add(v[k]);
      }

      // button
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(30));
      hbox.add(new qx.ui.core.Spacer(30, 40), { flex : 2 });
      hbox.add(this.getGenerateButton(), { flex : 1 });
      hbox.add(new qx.ui.core.Spacer(30, 40), { flex : 2 });

      this.getVerticalBox().add(hbox);
    },


    /**
     * loadInitialData():
     *
     * @return {void} 
     */
    _loadInitialData : function()
    {
      var hopts = {};
      hopts["url"] = this.getInitialDataUrl() + this.getReportName();
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
      this.setPrintMethod(remoteData["print_method"]);

      for (var w in remoteData["widgets"])
      {
        var h = remoteData["widgets"][w];
        this._createWidget(h);
      }

      this._createLayout();
      this._doShow();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _generate_cb : function()
    {
      var params = this._getReportParams();
      var hopts = { print_params : qx.util.Json.stringify(params) };
      var iframe = inventario.util.PrintManager.print(this.getPrintMethod(), hopts);
      var document = inventario.Application.appInstance.getRoot();

      document.add(iframe,
      {
        bottom : 1,
        right  : 1
      });
    },


    /**
     * TODOC
     *
     * @param widgetDef {var} TODOC
     * @return {void} 
     */
    _createWidget : function(widgetDef)
    {
      var w = null;
      var opts = widgetDef["options"];

      switch(widgetDef["widget_type"])
      {
        case "combobox_selector":
          w = new inventario.widget.ComboboxSelector(opts["label"], opts["cb_options"], opts["width"]);
          break;

        case "combobox_filtered":
          w = new inventario.widget.ComboBoxFiltered(opts.label, opts.cbs_options, opts.width);
          w.setDataRequestUrl(opts.data_request_url);
          break;

        case "checkbox_selector":
          w = new inventario.widget.CheckboxSelector(opts["label"], opts["cb_options"], opts["max_column"]);
          break;

        case "column_value_selector":
          w = new inventario.widget.ColumnValueSelector(opts["col_options"]);
          break;

        case "date_range":
          w = new inventario.widget.DateRange();

          if (typeof opts["since"] != "undefined" && typeof opts["since"] != "undefined") {
            w.setValue(opts["since"], opts["to"]);
          }

          break;

        case "list_selector":
          w = new inventario.widget.ListSelector(opts["label"], opts["list_name"]);
          break;

        case "hierarchy_on_demand":
          w = new inventario.widget.HierarchyOnDemand(null, opts);
          break;

        case "text_area":
          w = new qx.ui.form.TextArea();
          break;

        case "multiple_hierarchy":
          w = new inventario.widget.MultipleHierarchySelection(opts);
          break;

        default:
          alert("Error : " + widgetDef["widget_type"]);
      }

      this.getDataTypes().push(widgetDef["widget_type"]);
      this.getWidgetArray().push(w);
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _getReportParams : function()
    {
      var params = new Array();

      var v = this.getWidgetArray();

      for (var k in v)
      {
        var widget = v[k];
        var val = inventario.widget.Form.getInputValue(widget);
        params.push(val);
      }

      return params;
    }
  }
});