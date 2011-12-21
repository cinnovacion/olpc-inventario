
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
// DataImporter.js
// Loads files that are required by some scripts.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// 2009
qx.Class.define("inventario.widget.DataImporter",
{
  extend : inventario.window.AbstractWindow,

  construct : function(page)
  {
    this.base(arguments, page);
    this._modelsCombo = null;
    this._formatsCombo = null;
  },

  statics :
  {
    launch : function(page)
    {
      var dataImport = new inventario.widget.DataImporter(null);
      dataImport.setPage(page);
      dataImport.setUsePopup(true);
      dataImport.show();
    }
  },

  properties :
  {
    initialDataUrl :
    {
      check : "String",
      init  : "/data_import/initialData"
    },

    verticalBox : { check : "Object" },

    saveUrl :
    {
      check : "String",
      init  : "/data_import/import"
    },

    fileUploadWidget :
    {
      check    : "Object",
      init     : null,
      nullable : true
    }
  },

  members :
  {
    show : function() {
      this._loadInitialData();
    },

    _doShow : function()
    {
      this._doShow2(this.getVerticalBox());
      this.setWindowTitle(qx.locale.Manager.tr("Data Importer"));
    },

    _getFormData : function()
    {
      var resp = {};
      resp.model = inventario.widget.Form.getInputValue(this._modelsCombo);
      resp.format = inventario.widget.Form.getInputValue(this._formatsCombo);
      resp.place_id = this._placeHierarchy.getValue();
      return resp;
    },

    _createLayout : function(modelsDesc, formatsDesc)
    {
      var mainVBox = new qx.ui.container.Composite(new qx.ui.layout.VBox());

      this._modelsCombo = new qx.ui.form.SelectBox;
      inventario.widget.Form.loadComboBox(this._modelsCombo, modelsDesc, true);

      this._formatsCombo = new qx.ui.form.SelectBox;
      inventario.widget.Form.loadComboBox(this._formatsCombo, formatsDesc, true);

      this._placeHierarchy = new inventario.widget.HierarchyOnDemand(null, { width : 200, height : 200 });

      var uploadForm = new uploadwidget.UploadForm('uploadForm', this.getSaveUrl());  // ?????
      uploadForm.setLayout(new qx.ui.layout.Basic);

      var file = new uploadwidget.UploadField('data', qx.locale.Manager.tr("Browse"), 'icon/16/actions/document-save.png');

      uploadForm.add(file,
      {
        left : 0,
        top  : 0
      });

      this.setFileUploadWidget(uploadForm);

      var button = new qx.ui.toolbar.Button(qx.locale.Manager.tr("Import"), "inventario/22/adobe-reader.png");
      button.addListener("execute", this._import_cb, this);

      mainVBox.add(this._modelsCombo);
      mainVBox.add(this._formatsCombo);
      mainVBox.add(this._placeHierarchy);
      mainVBox.add(uploadForm);
      mainVBox.add(button);
      this.setVerticalBox(mainVBox);
      this._doShow();
    },

    _loadInitialData : function()
    {
      var hopts = {};
      hopts["url"] = this.getInitialDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadInitialDataResp;
      hopts["data"] = {};

      inventario.transport.Transport.callRemote(hopts, this);
    },

    _loadInitialDataResp : function(remoteData, params)
    {
      var definition = remoteData.definition;
      this._createLayout(definition.models, definition.formats);
    },

    _import_cb : function()
    {
      var combosData = this._getFormData();

      var opts =
      {
        url        : this.getSaveUrl(),
        parametros : null,
        handle     : this._import_cb_resp,

        // data       : qx.util.Json.stringify(combosData)
        data       : combosData
      };

      if (this.getFileUploadWidget())
      {
        opts.file_upload = true;
        opts.file_upload_form = this.getFileUploadWidget();
      }

      inventario.transport.Transport.callRemote(opts, this);
    },

    _import_cb_resp : function(remoteData, handleParams)
    {
      var msg = (remoteData["msg"] ? remoteData["msg"] : qx.locale.Manager.tr(" Data successfully imported."));
      inventario.window.Mensaje.mensaje(msg);
    }
  }
});
