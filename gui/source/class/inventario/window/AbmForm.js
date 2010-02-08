
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
// AbmForm.js
// fecha: 2007-05-18
// autor: Raul Gutierrez S.
//
//
// TODO: calcular el tamanho del popup
/**
 * Esta clase utiliza 2 metodos:
 *
 * 1) initialDataUrl: de aca obtenemos la info de como armar el formulario
 * 2) saveUrl: guardar datos del formulario (en RoR seria crear un nuevo objeto)
 *
 * @param page {}  Puede ser null
 * @param oMethods {Hash}  hash de configuracion {searchUrl,initialDataUrl,...}
 * @return void
 */
qx.Class.define("inventario.window.AbmForm",
{
  extend : inventario.window.AbstractWindow,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function(page, oMethods)
  {
    inventario.window.AbstractWindow.call(this, page);
    this.prepared = false;

    /* tamanho por default */

    this.setUsePopup(true);

    // this.setAbstractPopupWindowHeight(450);
    // this.setAbstractPopupWindowWidth(400);
    this.setEditIds(new Array());

    /* Cargar parametros sinhe quae non */

    try
    {
      if (oMethods.initialDataUrl) {
        this.setInitialDataUrl(oMethods.initialDataUrl);
      }

      if (oMethods.saveUrl) {
        this.setSaveUrl(oMethods.saveUrl);
      }
    }
    catch(e)
    {
      alert("Falta un parametro en el hash de urls! " + e);
    }
  },




  /*
      *****************************************************************************
         PROPERTIES
      *****************************************************************************
      */

  properties :
  {

    /* Parametros funcionales */

    showSaveButton :
    {
      check : "Boolean",
      init  : true
    },

    showCloseButton :
    {
      check : "Boolean",
      init  : true
    },

    closeAfterInsert :
    {
      check : "Boolean",
      init  : true
    },

    windowPopup :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    editIds :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    editRow :
    {
      check : "Number",
      init  : 0
    },

    details :
    {
      check : "Boolean",
      init  : false
    },

    vista :
    {
      check : "String",
      init  : ""
    },

    /*
             *  RPC
             */

    initialDataUrl :
    {
      check : "String",
      init  : ""
    },

    saveUrl :
    {
      check : "String",
      init  : ""
    },

    /*
             * Callbacks
             */

    saveCallback :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    saveCallbackObj :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /*
             * Widgets & icons
             */

    windowIcon :
    {
      check : "String",
      init  : "icon/22/actions/document-new.png"
    },

    vbox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /*
             *  Objs. auxiliares
             */

    dataInputObjects :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    saveColsMapping :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    extraData :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    verifySave :
    {
      check : "Boolean",
      init  : false
    },

    verifySaveUrl :
    {
      check : "String",
      init  : ""
    },

    fileUploadWidget :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    clearFormFieldsAfterSave :
    {
      check : "Boolean",
      init  : false
    },

    askSaveConfirmation :
    {
      check : "Boolean",
      init  : true
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
      if (!this.prepared) {
        this._loadInitialData();
      } else {
        this._doShow();
      }
    },


    /**
     * _doShow()
     *
     * @return {void} void
     */
    _doShow : function()
    {
      var vbox = this.getVbox();
      this._doShow2(vbox);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _loadInitialData : function()
    {
      var data = {};
      var viewDetails = false;
      var editRow = this.getEditRow();
      var details = this.getDetails();
      var ids = this.getEditIds();
      var vista = this.getVista();

      if (editRow > 0)
      {
        data["id"] = editRow;
        if (details) viewDetails = true;
      }
      else if (ids.length > 0)
      {
        data["ids"] = qx.util.Json.stringify(ids);
      }

      if (vista != "") data["vista"] = vista;

      if (this.getExtraData()) {
        data["extra_data"] = qx.util.Json.stringify(this.getExtraData());
      }

      var url = this.getInitialDataUrl();

      inventario.transport.Transport.callRemote(
      {
        url        : url,
        parametros : viewDetails,
        handle     : this._loadInitialDataResp,
        data       : data
      },
      this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} 
     */
    _loadInitialDataResp : function(remoteData, handleParams)
    {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20), { height : 400 });

      var datos = remoteData["fields"];
      var len = datos.length;

      this._editingFlag = false;
      this._formFields = new Array();
      this._remote_id = 0;
      this._remote_ids = new Array();
      this._update_checkboxes = new Array();
      this.setDataInputObjects(new Array());

      // Begin adding Tab support:
      this._tabView = new qx.ui.tabview.TabView();
      this._tabView.setWidth(500);
      vbox.add(this._tabView);

      // End.
      this.setVbox(vbox);

      // TODO: take to _initParams()
      if (remoteData["verify_before_save"])
      {
        this.setVerifySave(true);
        this.setVerifySaveUrl(remoteData["verify_save_url"]);
      }

      if (this.getDetails()) {
        this.setWindowTitle("Detalles");
      }

      if (remoteData["id"])
      {
        this._editingFlag = true;
        this._remote_id = remoteData["id"];
        if (this.getWindowTitle() == "") this.setWindowTitle("Editar");
      }
      else if (remoteData["ids"])
      {
        this._editingFlag = true;
        this._remote_ids = remoteData["ids"];

        if (this.getWindowTitle() == "") {
          this.setWindowTitle("Editar");
        }
      }
      else
      {
        remoteData["id"];
        if (this.getWindowTitle() == "") this.setWindowTitle("Agregar");
      }

      if (remoteData["window_title"]) {
        this.setWindowTitle(remoteData["window_title"]);
      }

      /*
                   * Si venimos de otro AbmForm tal vez tenga una manera especial de pasar los datos
                   */

      if (remoteData["save_cols_mapping"]) {
        this.setSaveColsMapping(remoteData["save_cols_mapping"]);
      }

      /* HACK: hasta que podamos calcular el tamanho de la ventana automaticamente... */

      if (remoteData["window_width"])
      {
        var w = parseInt(remoteData["window_width"]);
        this.setAbstractPopupWindowWidth(w);
      }

      if (remoteData["window_height"])
      {
        var h = parseInt(remoteData["window_height"]);
        this.setAbstractPopupWindowHeight(h);
      }

      var tab_page_title = remoteData.first_tab_title ? remoteData.first_tab_title : "Principal";
      gl = this._buildTabPageWithGrid(tab_page_title);

      var row_count = 0;

      for (var i=0; i<len; i++)
      {
        if (datos[i].datatype == "tab_break") {
          gl = this._buildTabPageWithGrid(datos[i].title, datos[i].icon);
        }
        else
        {
          try
          {
            var field_data = this._buildField(datos[i], handleParams);

            if (field_data.drill_down_vbox)
            {
              gl.add(field_data.drill_down_vbox,
              {
                row    : row_count,
                column : 0
              });
            }
            else
            {
              gl.add(field_data.label,
              {
                row    : row_count,
                column : 0
              });

              gl.add(field_data.input,
              {
                row    : row_count,
                column : 1
              });

              if (remoteData["needs_update"])
              {
                var update_cb = new qx.ui.form.CheckBox();

                gl.add(update_cb,
                {
                  row    : rowIndex,
                  column : 2
                });

                this._update_checkboxes.push(update_cb);
              }
            }
          }
          catch(e)
          {
            var str = "Problema al agregar el elemento num " + i + " de tipo " + datos[i].datatype;
            str += " con label " + datos[i].label + ". Excecpion: " + e;
            alert(str);
          }

          row_count++;
        }
      }

      if (!handleParams)
      {
        if (this.getShowSaveButton() || this.getShowCloseButton())
        {
          var hbox = this._buildButtonsHbox();
          this.getVbox().add(hbox);
        }
      }

      this.prepared = true;
      this._doShow();
    },

    /*
             * Metodo publico para guardar datos.
             */

    /**
     * TODOC
     *
     * @param callback_func {var} TODOC
     * @param callback_obj {var} TODOC
     * @return {void} 
     */
    saveData : function(callback_func, callback_obj)
    {
      var fields = this._formFields;
      var editing = false;
      var id = this.getEditRow();
      var ids = this.getEditIds();

      if (parseInt(id) > 0 || ids.length > 0) {
        editing = true;
      }

      this.setSaveCallback(callback_func);
      this.setSaveCallbackObj(callback_obj);

      if (ids.length == 0) {
        this._saveFormData(editing, fields, id);
      } else {
        this._saveFormData(editing, fields, ids);
      }
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _buildButtonsHbox : function()
    {
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(30));
      var spacer = new qx.ui.core.Spacer(30, 40);

      hbox.add(spacer, { flex : 1 });

      if (this.getShowSaveButton())
      {
        var saveButStr = (this._remote_id != 0 || this._remote_ids.length > 0 ? "Guardar Cambios" : "Guardar");
        var bSave = new qx.ui.form.Button(saveButStr, "inventario/16/floppy2.png");
        bSave.addListener("execute", this._save_cb, this);
        this._addAccelerator("Control+G", this._save_cb, this);
        hbox.add(bSave, { flex : 1 });
      }

      if (this.getShowCloseButton())
      {
        var bCancel = new qx.ui.form.Button("Cerrar", "inventario/16/no.png");
        bCancel.addListener("execute", this._cancel_cb, this);
        hbox.add(bCancel, { flex : 1 });
      }

      var spacer = new qx.ui.core.Spacer(30, 40);
      hbox.add(spacer, { flex : 1 });

      return hbox;
    },


    /**
     * TODOC
     *
     * @param tabTitle {var} TODOC
     * @param icon {var} TODOC
     * @return {var} TODOC
     */
    _buildTabPageWithGrid : function(tabTitle, icon)
    {
      if (!icon) icon = "icon/16/apps/utilities-terminal.png";

      var currentTab = new qx.ui.tabview.Page(tabTitle, icon);
      currentTab.setLayout(new qx.ui.layout.VBox());
      var grid_lo = new qx.ui.layout.Grid();
      grid_lo.setColumnFlex(0, 1);
      grid_lo.setColumnFlex(1, 3);
      var gl = new qx.ui.container.Composite(grid_lo);
      currentTab.add(gl);
      this._tabView.add(currentTab);
      return gl;
    },

    /*
             * TODO: validaciones
             * fieldData.required;
             * fieldData.validation;
             */

    /**
     * TODOC
     *
     * @param fieldData {var} TODOC
     * @param readOnly {var} TODOC
     * @return {var} TODOC
     */
    _buildField : function(fieldData, readOnly)
    {
      var input;
      var drill_down_vbox = null;
      var rAccelKey = fieldData["accel_key"];  /* Cargo el acelerador de tecla si tiene */

      if (rAccelKey)
      {
        var rLabel = fieldData.label;
        var label = new qx.ui.basic.Label(this._underlineLabel(rLabel, rAccelKey));
      }
      else
      {
        var label = new qx.ui.basic.Label();

        label.set(
        {
          rich    : true,
          value : "<b>" + fieldData.label + "</b>"
        });
      }

      switch(fieldData.datatype)
      {
        case "date":
          input = new qx.ui.form.DateField();

          if (fieldData.value)
          {
            // se presume formato dd-mm-yyyy
            var tmpV = fieldData.value.split("-");
            var _year = tmpV[2];
            var _month = Number(tmpV[1]) - 1;
            var _date = tmpV[0];
            input.setValue(new Date(_year, _month, _date));
          }

          break;

        case "numericfield":
            var max = fieldData.max ? fieldData.max : 99999999999999999999999999999;
            var min = fieldData.min ? fieldData.min : 0;
            var cur = fieldData.value ? fieldData.value : 0;
            var nf  = new qx.util.format.NumberFormat();
            input   = new qx.ui.form.Spinner(min, cur, max);
            nf.setMaximumFractionDigits(2);
            input.setNumberFormat(nf);


            break;
        case "textfield":
            input = new qx.ui.form.TextField(fieldData.value ? fieldData.value.toString() : "");

          if (fieldData.align) {
            input.setTextAlign(fieldData.align);
          }

          // Pregunto si el boton que se presiono es detalles, entonces el campo solo ReadOnly
          if (readOnly) input.setReadOnly(true);
          break;

        case "checkbox":
          input = new qx.ui.form.CheckBox();
          input.setValue(fieldData.value ? fieldData.value : false);

          break;

        case "checkbox_selector":
          input = new inventario.widget.CheckboxSelector("", fieldData.cb_options, fieldData.max_column);
          break;

        case "permissions":

          input = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
          permissionsObj = new inventario.widget.Permissions(null, fieldData.tree);
          permissionsObj.setPage(input);
          permissionsObj.show();

          this._formFields.push(permissionsObj);
          this.getDataInputObjects().push(permissionsObj);

          break;

        case "map_locator":

          var placeId = fieldData.placeId;
          var width = fieldData.width;
          var height = fieldData.height;

          if (!readOnly) {
            var readOnly = fieldData.readOnly;
          }

          input = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
          var mapWidget = new inventario.widget.MapLocator(null, placeId, readOnly, width, height, false);
          mapWidget.setPage(input);
          mapWidget.show();

          this._formFields.push(mapWidget);
          this.getDataInputObjects().push(mapWidget);

          break;

        case "dynamic_delivery_form":
          input = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
          var dynDelForm = new inventario.widget.DynamicDeliveryForm(null);
          dynDelForm.setPage(input);
          dynDelForm.show();

          this._formFields.push(dynDelForm);
          this.getDataInputObjects().push(dynDelForm);

          break;

        case "coords_text_field":

          input = new inventario.widget.CoordsTextField(fieldData.value ? fieldData.value.toString() : "");
          break;

        case "multiple_choice_form_maker":

          input = new inventario.widget.MultipleChoiceFormMaker(fieldData.questions);
          break;

        case "textarea":
          input = new qx.ui.form.TextArea(this._editingFlag && fieldData.value ? fieldData.value.toString() : "");

          // Pregunto si el boton que se presiono es detalles, entonces el campo solo ReadOnly
          if (readOnly) input.setReadOnly(true);
          var width, height;

          if (fieldData.width && fieldData.height)
          {
            width = parseInt(fieldData.width);
            height = parseInt(fieldData.height);
          }
          else
          {  /* a sound default */
            width = 250;
            height = 250;
          }

          /* el grid tiene que poder contener esto! */

          break;

        case "passwordfield":

          var password = fieldData.value ? fieldData.value : "";
          input = new qx.ui.form.PasswordField(password);

          // Pregunto si el boton que se presiono es detalles, entonces el campo solo ReadOnly
          if (readOnly) input.setReadOnly(true);
          break;

        case "question_form":
          var questionary = fieldData.options;
          input = new inventario.widget.QuestionForm(questionary);
          break;

        case "combobox":
          input = new qx.ui.form.SelectBox;

          var options = fieldData.options;
          inventario.widget.Form.loadComboBox(input, options, true);

          if (fieldData.vista)
          {
            input.setUserData("vista", fieldData.vista);
            input.setUserData("vista_widget", fieldData.vista_widget.toString());
            input.addListener("changeValue", this._set_select_vista_cb, this);
          }

          break;

        case "combobox_filtered":
          input = new inventario.widget.ComboBoxFiltered("", fieldData.cbs_options, fieldData.width);
          input.setDataRequestUrl(fieldData.data_request_url);
          break;

        case "select":
          input = new inventario.widget.Select(fieldData.option);

          /* Le agrego un accelerador de teclas a los botones .. */

          if (rAccelKey) {
            this._addAccelerator(rAccelKey, input.activar, input);
          }

          var options = fieldData.options;

          inventario.widget.Form.loadComboBox(input.getComboBox(), options, true);

          /* Se reconozca vista, que se manda por el servidor */
          if (fieldData.vista != null) {
              input.getAbm().setVista(fieldData.vista);
          }

          input.getAbm().setAskConfirmationOnClose(false);

          if (fieldData.text_value) {
            input.getComboBox().setUserData("text_value", true);
          }

          this._formFields.push(input.getComboBox());

          this.getDataInputObjects().push(input);

          /* Verifico si el boton agregar del abm2 me pide un multiAbmForm */

          if (fieldData.abm_form == "multi")
          {
            var configs = new Array();
            can_tabs = fieldData.tabs.length;

            for (var z=0; z<can_tabs; z++)
            {
              url = fieldData.tabs[z].url;
              titulo = fieldData.tabs[z].titulo;
              var res = inventario.widget.Url.getUrl(url);

              configs.push(
              {
                InitialDataUrl : res["addUrl"],
                SaveUrl        : res["saveUrl"],
                titulo         : titulo,
                select         : url,
                showSelect     : true
              });
            }

            input.getAbm().setMultiAbmFormConfigs(configs);
          }

          break;

        case "table":
          input = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));

          var rows_num = (fieldData.rows_num ? fieldData.rows_num : 5);
          var width = (fieldData.width ? fieldData.width : 250);
          var height = (fieldData.height ? fieldData.height : 250);

          var tableObj = new inventario.widget.Table2();
          tableObj.setUseEmptyTable(true);
          tableObj.setRowsNum(rows_num);
          tableObj.setColsNum(fieldData["col_titles"].length);
          tableObj.setTitles(fieldData["col_titles"]);
          tableObj.setEditables(fieldData["editables"]);
          tableObj.setWidths(fieldData["widths"]);
          tableObj.setPage(input);
          tableObj.setButtonsAlignment("center");

          if (fieldData["columnas_visibles"]) {
            tableObj.setColumnasVisibles(fieldData["columnas_visibles"]);
          }

          /*
                    	     * Si estamos en modo "Detalles" no nos interesa poder agregar cosas a la tabla
                    	     */

          if (this.getDetails()) {
            tableObj.setWithButtons(false);
          } else {
            tableObj.setWithButtons(true);
          }

          tableObj.setShowSelectButton(false);
          tableObj.setShowModifyButton(false);
          tableObj.setAddButtonLabel("+");
          tableObj.setAddButtonIcon("");
          tableObj.setDeleteButtonLabel("-");
          tableObj.setDeleteButtonIcon("");

          // ku 2007-05-16
          if (fieldData.options.length > 0) tableObj.setGridData(fieldData.options);

          // ////////////////////////////////
          tableObj.show();

          if (fieldData.cols_mapping) {
            tableObj.setUserData("cols_mapping", fieldData.cols_mapping);
          }

          tableObj.setHashKeys(fieldData.hashed_data);

          if (fieldData.formula_table)
          {
            tableObj.setFormulaTable(fieldData.formula_table);
            tableObj.setFormulaContext(this);
          }

          if (!this.getDetails()) {
            this._doAddHandlerTable(fieldData, tableObj);
          }

          this._formFields.push(tableObj);
          this.getDataInputObjects().push(tableObj);
          break;

        case "uploadfield":
          input = new uploadwidget.UploadForm('uploadFrm', this.getSaveUrl());
          input.setLayout(new qx.ui.layout.Basic);

          var file = new uploadwidget.UploadField(fieldData.field_name, 'Examinar', 'icon/16/actions/document-save.png');
          input.add(file,
          {
            left : 0,
            top  : 0
          });

          this.setFileUploadWidget(input);

          break;

        case "image":
          input = new qx.ui.basic.Image(fieldData.value);

          // input.setScale(true);
          // input.setWidth(64);
          // input.setHeight(64);
          break;

        case "hierarchy_on_demand":
          var dataHash = typeof fieldData.dataHash != "undefined" ? fieldData.dataHash : null;
          var options = typeof fieldData.options != "undefined" ? fieldData.options : null;
          input = new inventario.widget.HierarchyOnDemand(dataHash, options);
          break;

        case "dyntable":
          input = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
          var dynTableObj = new inventario.widget.DynTable();

          dynTableObj.setColumnsData(fieldData.options);

          var optsLen = fieldData.options.length;

          var table_data = {};
          table_data.col_titles = new Array();
          table_data.widths = new Array();
          table_data.hashed_data = new Array();

          for (var j=0; j<optsLen; j++)
          {
            table_data.col_titles.push(fieldData.options[j].label);
            table_data.widths.push(fieldData.widths[j]);
            table_data.hashed_data.push(fieldData.options[j].label);
          }

          dynTableObj.setTableDef(table_data);

          dynTableObj.setPage(input);
          dynTableObj.show();

          if (fieldData.data) {
            dynTableObj.setTableData(fieldData.data);
          }

          this._formFields.push(dynTableObj);
          this.getDataInputObjects().push(dynTableObj);

          break;

        case "drilldown_info":
          drill_down_vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));
          var scroller = new qx.ui.container.Scroll();

          // scroller.set({ width: 400,  height: 300 });
          var container = new qx.ui.container.Composite(new qx.ui.layout.VBox());
          container.setAllowGrowX(false);
          container.setAllowStretchX(false);
          scroller.add(container);
          drill_down_vbox.add(scroller);

          var objs = fieldData.value;
          var len = objs.length;

          for (var i=0; i<len; i++)
          {
            var label = objs[i].object_desc ? objs[i].object_desc : " ";
            var gbox = new qx.ui.groupbox.GroupBox(label, "icon/16/apps/utilities-text-editor.png");
            gbox.setLayout(new qx.ui.layout.VBox());
            gbox.add(this._buildDrillDownInfo(objs[i]));

            container.add(gbox);
          }

          break;

        default:
          alert(fieldData.datatype);
      }

      // esto se tendria que cambiar
      if (fieldData.datatype != "select" && fieldData.datatype != "table" && fieldData.datatype != "uploadfield" && fieldData.datatype != "image" && fieldData.datatype != "dyntable" && fieldData.datatype != "permissions" && fieldData.datatype != "map_locator" && fieldData.datatype != "dynamic_delivery_form")
      {
        this._formFields.push(input);

        /* Guardo tb. en una propiedad el input widget p/ poder acceder a el via el manejador de formulas de Table2.
                	     * TODO: En realidad fields ya no haria falta pq se puede usar dataInputObjects
                	     */

        this.getDataInputObjects().push(input);
      }

      var ret = {};

      if (drill_down_vbox) {
        ret.drill_down_vbox = drill_down_vbox;
      }
      else
      {
        ret.label = label;
        ret.input = input;
      }

      return ret;
    },


    /**
     * _saveFormData(): enviar datos p/ que se cree el nuevo objeto en el servidor (o se guarde la edicion)
     *
     * @param editing {var} editando o creando?
     * @param fields {var} TODOC
     * @param id {var} en caso de que estemos editando
     * @return {void} void
     */
    _saveFormData : function(editing, fields, id)
    {
      try
      {
        // data
        var updated = this._getDataFromFields(fields);

        if (this._update_checkboxes.length > 0 && updated == false)
        {
          alert("Debe marcar al menos un campo");
          return;
        }

        var msgConfirmacion;

        if (editing)
        {
          if (typeof (id) == "object")
          {
            // batch edit
            this.data["ids"] = id;
            this.setEditIds(new Array());
            msgConfirmacion = "Estos cambios seran aplicados a estos " + id.length.toString() + " registros. Esta seguro?";
          }
          else
          {
            this.data["id"] = id;
            msgConfirmacion = "Guardar cambios?";
          }
        }
        else
        {
          msgConfirmacion = "Crear?";
        }

        if (this._verify_msg != "") {
          msgConfirmacion += "\n\n" + this._verify_msg;
        }

        if (this.getAskSaveConfirmation() == false || confirm(msgConfirmacion))
        {
          var url = this.getSaveUrl();

          if (url == "" || url == null)
          {

            /* vamos a insertarnos dentro de una tabla */

            var table = this.getUserData("table_obj");
            this.setSaveCallback(this._addRow2Table);
            this.setSaveCallbackObj(this);

            /* Si tenemos un mapa mapeamos regeneramos el vector de datos */

            if (this.getSaveColsMapping()) {
              this.data["fields"] = this._getDataFromForm(this.getSaveColsMapping(), fields);
            }

            this._saveCallback(null, this.data["fields"]);

            if (this.getUsePopup() && this.getCloseAfterInsert()) {
              this.getAbstractPopupWindow().getWindow().close();
            }
          }
          else
          {
            var payload = qx.util.Json.stringify(this.data);
            var data = { payload : payload };

            if (this.getExtraData()) {
              data["extra_data"] = qx.util.Json.stringify(this.getExtraData());
            }

            var vista = this.getVista();
            if (vista != "") data["vista"] = vista;

            var opts =
            {
              url        : url,
              parametros : null,
              handle     : this._saveFormDataResp,
              data       : data
            };

            if (this.getFileUploadWidget())
            {
              opts["file_upload"] = true;
              opts["file_upload_form"] = this.getFileUploadWidget();
            }

            inventario.transport.Transport.callRemote(opts, this);
          }
        }
      }
      catch(e)
      {
        alert(e.toString());
      }
    },


    /**
     * la idea seria que cuando se agrega o modifica una fila, llame otra vez al servidor
     * para que traiga la fila de lo que se agrego
     *  _saveDataResp()
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} void
     */
    _saveFormDataResp : function(remoteData, handleParams)
    {
      this._saveCallback(remoteData, this.data["fields"]);

      if (this.getUsePopup() && this.getCloseAfterInsert()) {
        this.getAbstractPopupWindow().getWindow().close();
      }

      if (this.getClearFormFieldsAfterSave()) {
        this._clearFormFields();
      }
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _clearFormFields : function() {
      inventario.widget.Form.resetInputs(this._formFields);
    },

    /* remoteData podria ser Null si no hubo RPC y solo se esta yendo a una tabla */

    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param newData {var} TODOC
     * @return {void} 
     */
    _saveCallback : function(remoteData, newData)
    {
      var f = this.getSaveCallback();
      var obj = this.getSaveCallbackObj();

      if (f)
      {
        obj = (obj ? obj : this);
        f.call(obj, newData, remoteData);
      }
    },


    /**
     * TODOC
     *
     * @param newRow {var} TODOC
     * @param remoteDataIgnored {var} TODOC
     * @return {void} 
     */
    _addRow2Table : function(newRow, remoteDataIgnored)
    {
      var tableObj = this.getUserData("table_obj");
      tableObj.addRows([ newRow ], -1);
    },

    /*
             * _getDataFromForm()
             * @param remoteData
             * @param handleParams
             * @return  void
             */

    /**
     * TODOC
     *
     * @param colsMapping {var} TODOC
     * @param fields {var} TODOC
     * @return {var} TODOC
     */
    _getDataFromForm : function(colsMapping, fields)
    {
      var ret = new Array();
      var len = colsMapping.length;
      var v;

      for (var i=0; i<len; i++)
      {
        var j = colsMapping[i]["pos"];
        var input = fields[j];

        if (input instanceof qx.ui.form.TextField) {
          v = input.getValue();
        }
        else if (input instanceof qx.ui.form.SelectBox)
        {
          var s = input.getSelected();

          if (colsMapping[i]["data"] == "text") {
            v = input.getValue();
          } else if (colsMapping[i]["data"] == "value") {
            v = s.getValue();
          }
          else if (colsMapping[i]["data"] == "hash")
          {
            v =
            {
              value : s.getValue(),
              text  : input.getValue()
            };
          }
          else
          {
            alert("Error de config. en getDataFromForm");
          }
        }

        ret.push(v);
      }

      return ret;
    },


    /**
     * TODOC
     *
     * @param datos {var} TODOC
     * @param tableObj {var} TODOC
     * @return {void} 
     */
    _doAddHandlerTable : function(datos, tableObj)
    {
      if (datos.add_form_url)
      {
        /*
                	 * La tabla se cargar a partir de un nuevo formulario
                	 */

        this.setUserData("add_form_url", datos.add_form_url);
        this.setUserData("tableObje", tableObj);

        /*
                	 * WARNING
                	 *  Dentro de este handler se hacen referencias a tableObj, tableObj habria que pasar como una propiedad
                	 *  definida por usuario de getAddButton() y recuperar por ahi para no tener problemas con el scope dinamico
                	 */

        tableObj.getAddButton().addListener("execute", function(e)
        {
          var add_form = new inventario.window.AbmForm(null, {});
          add_form.setAskConfirmationOnClose(false);

          /* No establezco el callback...
                    	     * Lo delego (al asociar una tabla al nuevo AbmForm) p/ el momento de obtener los datos */

          add_form.setUserData("table_obj", this.getUserData("tableObje"));
          add_form.setSaveColsMapping();
          var url = this.getUserData("add_form_url");
          add_form.setInitialDataUrl(url);
          add_form.show();
        },
        this);
      }
      else
      {
        /*
                	 * La tabla se cargar a partir de un Abm2
                	 */

        tableObj.setUserData("abm_option", datos.option);

        if (datos.vista) {
          tableObj.setUserData("vista", datos.vista);
        }

        tableObj.getAddButton().addListener("execute", function() {
          this._table_add_cb(tableObj);
        }, this);
      }
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _save_cb : function(e)
    {
      this._verify_msg = "";

      /* Should we ask the server to verify the data? */

      if (this.getVerifySave())
      {
        var updated = this._getDataFromFields(this._formFields);
        var payload = qx.util.Json.stringify(this.data);
        var data = { payload : payload };
        var url = this.getVerifySaveUrl();

        var opts =
        {
          url        : url,
          parametros : null,
          handle     : this._verify_save_resp,
          data       : data
        };

        inventario.transport.Transport.callRemote(opts, this);
      }
      else
      {
        this._do_save_cb();
      }
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} 
     */
    _verify_save_resp : function(remoteData, handleParams)
    {
      this._verify_msg = remoteData["obj_data"];
      this._do_save_cb();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _do_save_cb : function()
    {
      var pId = (this._remote_ids.length > 0 ? this._remote_ids : this._remote_id);
      this._saveFormData(this._editingFlag, this._formFields, pId);
    },

    /* FIXME: esto esta roto.. */

    /**
     * TODOC
     *
     * @param tableObj {var} TODOC
     * @return {void} 
     */
    _table_add_cb : function(tableObj)
    {

      /* Handler p/ agregar filas */

      var handlerAbm2 = function(filas)
      {
        var nuevas_filas = new Array();
        var cols_mapping = tableObj.getUserData("cols_mapping");

        for (var j=0; j<filas.length; j++)
        {
          var tmp_fila = new Array();

          for (var k=0; k<cols_mapping.length; k++)
          {
            var indice_columna = cols_mapping[k];
            tmp_fila.push(filas[j][indice_columna]);
          }

          nuevas_filas.push(tmp_fila);
        }

        tableObj.addRows(nuevas_filas, -1);
      };

      /* Le pasamos una ref al combobox a ABM2 de tal forma a que el sepa que hacer cuando se clickea en elegir */

      var popup_win = new inventario.widget.Popup(tableObj.getUserData("abm_option"));
      popup_win.getAbm().setChooseButtonCallBack(handlerAbm2);
      popup_win.getAbm().setChooseButtonCallBackContext(this);

      /* Se reconozca vista, que se manda por el servidor */

      if (tableObj.getUserData("vista")) {
        popup_win.getAbm().setVista(tableObj.getUserData("vista"));
      }

      popup_win.show();
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _cancel_cb : function(e)
    {
      if (this.getUsePopup()) {
        this.getAbstractPopupWindow().getWindow().close();
      }
    },


    /**
     * TODOC
     *
     * @param fields {var} TODOC
     * @return {var} TODOC
     */
    _getDataFromFields : function(fields)
    {
      this.data = {};
      this.data["fields"] = new Array();
      var updated = false;

      for (var i=0; i<fields.length; i++)
      {
        var v = inventario.widget.Form.getInputValue(fields[i]);

        if (fields[i].getUserData("number_with_format")) {
          v = inventario.widget.Form.unFormatNumber(v);
        }

        // checkboxes: field updated?
        if (this._update_checkboxes.length > 0)
        {
          var h = {};
          h["value"] = v;

          h["updated"] = this._update_checkboxes[i].getChecked();

          if (h["updated"]) {
            updated = true;
          }

          this.data["fields"].push(h);
        }
        else
        {
          this.data["fields"].push(v);
        }
      }

      return updated;
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _set_select_vista_cb : function(e)
    {
      var cb = e.getTarget();
      var selected_val = inventario.widget.Form.getInputValue(cb);
      var vista = cb.getUserData("vista") + "_" + selected_val.toString();
      var j = parseInt(cb.getUserData("vista_widget"));

      this.getDataInputObjects()[j].getAbm().setVista(vista);
    },


    /**
     * TODOC
     *
     * @param hOpts {Map} TODOC
     * @return {var} TODOC
     */
    _buildDrillDownInfo : function(hOpts)
    {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));

      if (hOpts.objs)
      {
        var len = hOpts.objs.length;

        for (var i=0; i<len; i++) {
          vbox.add(this._doBuildDrillDownInfo(hOpts.objs[i]));
        }
      }
      else
      {
        vbox.add(this._doBuildDrillDownInfo(hOpts));
      }

      return vbox;
    },


    /**
     * TODOC
     *
     * @param hOpts {Map} TODOC
     * @return {var} TODOC
     */
    _doBuildDrillDownInfo : function(hOpts)
    {
      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox(20));
      var grid_lo = new qx.ui.layout.Grid();
      grid_lo.setColumnFlex(0, 1);
      grid_lo.setColumnFlex(1, 3);
      var gl = new qx.ui.container.Composite(grid_lo);
      hbox.add(gl);

      var row = 0;

      for (var k in hOpts)
      {
        var label = new qx.ui.basic.Label(k.toString());
        var value = new qx.ui.basic.Label(hOpts[k].toString());

        gl.add(label,
        {
          row    : row,
          column : 0
        });

        gl.add(value,
        {
          row    : row,
          column : 1
        });

        row++;
      }

      return hbox;
    }
  }
});
