
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
// DynamicBarcodeScanForm.js
// A simple dynamic form for lots creation.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// 2009
qx.Class.define("inventario.window.BarcodeScanForm",
{
  extend : inventario.window.AbstractWindow,

  construct : function(page, mode)
  {
    if (mode == "assignment")
      var title = this.tr("Mass assignment by barcode");
    else
      var title = this.tr("Mass movement by barcode");

    this.base(arguments, page, title);
    this._vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(10));
    this.add(this._vbox);
    this._mode = mode;
    this._amount = 0;
    this._amountLabel = null;

    this._movementTypeSelector = new qx.ui.form.SelectBox();

    this._placeSelector = new inventario.widget.HierarchyOnDemand(null);
    this._placeSelector.getTreeWidget().addListener("changeSelection", this._treeSelectionChanged, this);

    var msg = this.tr("Only without laptops in hands");
    if (this._mode == "assignment")
      msg = this.tr("Only without laptops assigned");
    this._filterCheck = new qx.ui.form.CheckBox(msg);

    this._placeForm = this._createPlaceForm();
    this._scanForm = this._createScanForm();

    var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox());
    this._vbox.add(hbox)

    this._backButton = new qx.ui.form.Button(this.tr("Back"));
    this._backButton.addListener("execute", this._backClicked, this);
    hbox.add(this._backButton);

    this._nextButton = new qx.ui.form.Button();
    this._nextButton.addListener("execute", this._nextClicked, this);
    hbox.add(this._nextButton);

    this._showPlace();

    if (this._mode == "movement")
      this._loadMovementTypes();
  },

  destruct : function() {
    this._disposeObjects("_placeForm", "_scanForm");
  },

  properties :
  {
    peopleDataUrl :
    {
      check : "String",
      init  : "/people/peopleAmount"
    },
    saveAssignmentUrl :
    {
      check : "String",
      init  : "/assignments/saveMassAssignment"
    },
    saveMovementUrl :
    {
      check : "String",
      init  : "/movements/saveMassMovement"
    },
    movementTypesUrl :
    {
      check : "String",
      init  : "/movement_types/getTypes"
    }
  },

  statics :
  {
    launch : function(page, options) {
      var form = new inventario.window.BarcodeScanForm(page, options["mode"]);
      form.open();
    },

    states : { PLACE: 0, SCAN: 1 }
  },

  members :
  {
    getValues : function()
    {
      var list = new Array();

      for (var i=0; i<this._amount; i++)
      {
        var personCodeBar = this._grid.getLayout().getCellWidget(i, 0).getValue();
        var laptopCodeBar = this._grid.getLayout().getCellWidget(i, 1).getValue();

        if (personCodeBar != "" && laptopCodeBar != "")
        {
          list.push(
          {
            person : personCodeBar,
            laptop : laptopCodeBar
          });
        }
      }

      return list;
    },

    _createPlaceForm : function()
    {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox());

      var label = new qx.ui.basic.Label("<b> " + this.tr("Place:") + "</b>");
      label.setRich(true);
      vbox.add(label);

      vbox.add(this._placeSelector);
      vbox.add(this._filterCheck);
      if (this._mode == "movement") {
        vbox.add(new qx.ui.core.Spacer(0, 20));
        label = new qx.ui.basic.Label("<b>" + this.tr("Create movements with type:") + "</b>");
        label.setRich(true);
        vbox.add(label);
        vbox.add(this._movementTypeSelector);
      }

      return vbox;
    },

    _createScanForm : function()
    {
      var subMainVbox = new qx.ui.container.Composite(new qx.ui.layout.VBox());

      var label = new qx.ui.basic.Label()
      label.setRich(true);
      label.setWidth(310);
      subMainVbox.add(label);
      if (this._mode == "assignment")
        label.setValue(this.tr("This form is for creating <b>assignments</b> of laptops in mass. For each assignment you wish to create, scan the barcode of the person and the barcode (serial number) of the laptop."));
      else
        label.setValue(this.tr("This form is for creating <b>movements</b> of laptops in mass. For each movement you wish to create, scan the barcode of the person and the barcode (serial number) of the laptop."));

      var grid = new qx.ui.container.Composite(new qx.ui.layout.Grid(50, 50));

      grid.add(new qx.ui.basic.Label(this.tr("#Person")),
      {
        row    : 0,
        column : 0
      });

      grid.add(new qx.ui.basic.Label(this.tr("#Laptop")),
      {
        row    : 0,
        column : 1
      });

      subMainVbox.add(grid);

      var scrollContainer = new qx.ui.container.Scroll();

      scrollContainer.set(
      {
        width  : 300,
        height : 180
      });

      subMainVbox.add(scrollContainer);

      this._grid = new qx.ui.container.Composite(new qx.ui.layout.Grid(5, 5));
      scrollContainer.add(this._grid);

      var amountLabel = new qx.ui.basic.Label(this.tr("Number of students: 0"));
      subMainVbox.add(amountLabel);

      this._amountLabel = amountLabel;
      return subMainVbox;
    },

    _loadMovementTypes : function()
    {
      var hopts = {};
      hopts["url"] = this.getMovementTypesUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadMovementTypesCb;
      inventario.transport.Transport.callRemote(hopts, this);
    },

    _loadMovementTypesCb : function(remoteData, params)
    {
      inventario.widget.Form.loadComboBox(this._movementTypeSelector, remoteData.types, true);
    },

    _loadStudentsAmount : function()
    {
      var hopts = {};
      hopts["url"] = this.getPeopleDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadStudentsAmountCb;

      hopts["data"] =
      {
        place_id   : this._placeSelector.getValue(),
        withFilter : this._filterCheck.getValue(),
        mode       : this._mode
      };

      inventario.transport.Transport.callRemote(hopts, this);
    },

    _loadStudentsAmountCb : function(remoteData, params)
    {
      this._amount = remoteData.amount;
      this._showScan();
    },

    _populateGrid : function() {
      // Remove children from grid in reverse order to avoid issues with
      // in-place array modification
      var children = this._grid.getChildren();
      for (var i = children.length - 1; i >= 0; i--) {
        var child = children[i];
        this._grid.removeAt(i);
        child.dispose();
      }

      for (var i = 0; i < this._amount; i++)
      {
        this._grid.add(this._createTextField(2 * i, 10, /(^$)|(^[0-9]{10}$)/),
        {
          row    : i,
          column : 0
        });

        this._grid.add(this._createTextField((2 * i) + 1, 11, /(^$)|(^[A-Z]{3}[(0-9)|(A-F)]{8}$)/),
        {
          row    : i,
          column : 1
        });
      }

      this._amountLabel.set({ value : this.tr("Number of students: ") + this._amount });
    },

    _createTextField : function(pos, jumpAt, expresion)
    {
      var textField = new qx.ui.form.TextField();

      textField.addListener("input", function()
      {
        if (textField.getValue().length >= jumpAt)
        {
          // Changes focus to the next widget.
          var j = (pos % 2 == 0) ? 1 : 0;
          var i = parseInt((pos / 2) + (1 - j));
          this._grid.getLayout().getCellWidget(i, j).focus();
        }
      },
      this);

      textField.addListener("focusout", function()
      {
        var text = textField.getValue();

        if (text != null && text.match(expresion) == null)
          alert(text + this.tr(" registration is not valid, check."));
      },
      this);

      return textField;
    },

    _doSaveCb : function(remoteData, params) {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);
      this.close();
    },

    _doSave : function() {
      var hopts = {};
      hopts["data"] = { deliveries: qx.lang.Json.stringify(this.getValues()) };

      if (this._mode == "assignment") {
        hopts["url"] = this.getSaveAssignmentUrl();
      } else {
        hopts["url"] = this.getSaveMovementUrl();
        var id = inventario.widget.Form.getInputValue(this._movementTypeSelector);
        hopts["data"]["movement_type"] = id
      }
      hopts["parametros"] = null;
      hopts["handle"] = this._doSaveCb;
      inventario.transport.Transport.callRemote(hopts, this);
    },

    _backClicked : function() {
      this._showPlace();
    },

    _nextClicked : function() {
      if (this._state == inventario.window.BarcodeScanForm.states.PLACE)
        this._loadStudentsAmount();
      else
        this._doSave();
    },

    _treeSelectionChanged : function() {
      this._nextButton.setEnabled(this._placeSelector.getValue() != -1);
    },

    _showScan : function() {
      this._state = inventario.window.BarcodeScanForm.states.SCAN;
      this._nextButton.setLabel(this.tr("Save"));
      this._nextButton.setEnabled(true);
      this._backButton.setEnabled(true);

      this._vbox.removeAt(0);
      this._vbox.addAt(this._scanForm, 0);

      this._populateGrid();
    },

    _showPlace : function() {
      this._state = inventario.window.BarcodeScanForm.states.PLACE;
      this._nextButton.setLabel(this.tr("Next"));
      this._backButton.setEnabled(false);

      /* to correctly set sensitivity of next button */
      this._treeSelectionChanged();

      if (this._vbox.getChildren().length > 1)
        this._vbox.removeAt(0);
      this._vbox.addAt(this._placeForm, 0);
    }
  }
});
