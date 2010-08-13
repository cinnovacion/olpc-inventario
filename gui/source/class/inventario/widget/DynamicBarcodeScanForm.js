
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
qx.Class.define("inventario.widget.DynamicBarcodeScanForm",
{
  extend : inventario.window.AbstractWindow,

  /*
       * CONSTRUCTOR
       */

  construct : function(page, mode)
  {
    this.base(arguments, page);
    this._mode = mode;
    this._fields = null;
    this._placesCombo = null;
    this._amountLabel = null;
    this._filterCheck = null;
    this._amount = 0;
  },

  /*
       * PROPERTIES
       */

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
      init  : "/people/studentsAmount"
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
    show : function() {
      this._loadInitialData();
    },


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
     * @return {var} TODOC
     */
    getValues : function()
    {
      var list = new Array();

      if (this._fields != null)
      {
        var grid = this._fields.getChildren();

        for (var i=0; i<this._amount; i++)
        {
          var personCodeBar = grid[0].getLayout().getCellWidget(i, 0).getValue();
          var laptopCodeBar = grid[0].getLayout().getCellWidget(i, 1).getValue();

          if (personCodeBar != "" && laptopCodeBar != "")
          {
            list.push(
            {
              person : personCodeBar,
              laptop : laptopCodeBar
            });
          }
        }
      }

      return list;
    },


    /**
     * TODOC
     *
     * @param places {var} TODOC
     * @return {void} 
     */
    _createLayout : function(places)
    {
      var mainVBox = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));

      mainVBox.add(this._addFilterCheckBox());
      mainVBox.add(this._addPlacesCombo(places));
      mainVBox.add(this._addForm());

      this.setVerticalBox(mainVBox);
      this._doShow();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _loadInitialData : function()
    {
      var hopts = {};
      hopts["url"] = this.getPlacesDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadInitialDataRespCb;
      hopts["data"] = { sections_only : true };

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadInitialDataRespCb : function(remoteData, params) {
      this._createLayout(remoteData.places);
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _addFilterCheckBox : function()
    {
      var msg = qx.locale.Manager.tr("Only without laptops in hands");
      if (this._mode == "assignation") {
        msg = qx.locale.Manager.tr("Only without laptops assigned");
      }
      var filterCheckeBox = new qx.ui.form.CheckBox(msg);
      filterCheckeBox.addListener("changeValue", this._loadForm, this);
      this._filterCheck = filterCheckeBox;
      return filterCheckeBox;
    },


    /**
     * TODOC
     *
     * @param places {var} TODOC
     * @return {var} TODOC
     */
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


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _addForm : function()
    {
      var subMainVbox = new qx.ui.container.Composite(new qx.ui.layout.VBox());

      var grid = new qx.ui.container.Composite(new qx.ui.layout.Grid(50, 50));

      grid.add(new qx.ui.basic.Label(qx.locale.Manager.tr("#Person")),
      {
        row    : 0,
        column : 0
      });

      grid.add(new qx.ui.basic.Label(qx.locale.Manager.tr("#Laptop")),
      {
        row    : 0,
        column : 1
      });

      subMainVbox.add(grid);

      var scrollContainer = new qx.ui.container.Scroll();

      scrollContainer.set(
      {
        width  : 300,
        height : 200
      });

      subMainVbox.add(scrollContainer);

      var fields = new qx.ui.container.Composite(new qx.ui.layout.VBox());
      scrollContainer.add(fields);

      var amountLabel = new qx.ui.basic.Label(qx.locale.Manager.tr("Number of students: 0"));
      subMainVbox.add(amountLabel);

      this._fields = fields;
      this._amountLabel = amountLabel;
      return subMainVbox;
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _loadForm : function()
    {
      var filterChecked = this._filterCheck.getValue();
      var placeId = inventario.widget.Form.getInputValue(this._placesCombo);
      var hopts = {};
      hopts["url"] = this.getPeopleDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadFormRespCb;

      hopts["data"] =
      {
        place_id   : placeId,
        withFilter : filterChecked,
        mode       : this._mode
      };

      inventario.transport.Transport.callRemote(hopts, this);
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadFormRespCb : function(remoteData, params)
    {
      this._fields.removeAll();
      var grid = new qx.ui.container.Composite(new qx.ui.layout.Grid(5, 5));

      var amount = remoteData.amount;

      // alert(amount.toString());
      for (var i=0; i<amount; i++)
      {
        grid.add(this._createTextField(grid, 2 * i, 10, /(^$)|(^[0-9]{10}$)/),
        {
          row    : i,
          column : 0
        });

        grid.add(this._createTextField(grid, (2 * i) + 1, 11, /(^$)|(^[A-Z]{3}[(0-9)|(A-F)]{8}$)/),
        {
          row    : i,
          column : 1
        });
      }

      this._fields.add(grid);
      this._amountLabel.set({ value : qx.locale.Manager.tr("Number of students: ") + amount.toString() });
      this._amount = amount;
    },


    /**
     * TODOC
     *
     * @param parent {var} TODOC
     * @param pos {var} TODOC
     * @param jumpAt {var} TODOC
     * @param expresion {var} TODOC
     * @return {var} TODOC
     */
    _createTextField : function(parent, pos, jumpAt, expresion)
    {
      var textField = new qx.ui.form.TextField();

      textField.addListener("input", function()
      {
        if (textField.getValue().length >= jumpAt)
        {
          // Changes focus to the next widget.
          var j = (pos % 2 == 0) ? 1 : 0;
          var i = parseInt((pos / 2) + (1 - j));
          parent.getLayout().getCellWidget(i, j).focus();
        }
      },
      this);

      textField.addListener("focusout", function()
      {
        var text = textField.getValue();

        if (text.match(expresion) == null) {
          alert(text + qx.locale.Manager.tr(" registration is not valid, check."));
        }
      },
      this);

      return textField;
    }
  }
});
