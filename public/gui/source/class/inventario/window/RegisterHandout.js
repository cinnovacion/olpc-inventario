//     Copyright Daniel Drake 2012
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

qx.Class.define("inventario.window.RegisterHandout",
{
  extend : inventario.window.AbstractWindow,

  construct : function()
  {
    var title = this.tr("Register handout");
    this.base(arguments, title);
    this._people = [];

    this.setWidth(300);
    this.getVbox().getLayout().setSpacing(0);

    var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox());
    hbox.setPaddingTop(10)
    this.getVbox().add(hbox);

    this._backButton = new qx.ui.form.Button(this.tr("Back"));
    this._backButton.addListener("execute", this._backClicked, this);
    hbox.add(this._backButton);

    this._nextButton = new qx.ui.form.Button(this.tr("Next"));
    this._nextButton.addListener("execute", this._nextClicked, this);
    hbox.add(this._nextButton);

    this._movementTypeSelector = new qx.ui.form.SelectBox();
    this._commentField = new qx.ui.form.TextField();
    this._modeRadioGroup = new qx.ui.form.RadioButtonGroup();
    this._serialsTextArea = new qx.ui.form.TextArea();

    this._placeSelector = new inventario.widget.HierarchyOnDemand(null);
    this._placeSelector.getTreeWidget().addListener("changeSelection", this._placeSelectionChanged, this);

    /* VBox to load list of person checkboxes */
    this._peopleBox = new qx.ui.container.Composite(new qx.ui.layout.VBox());

    this._introForm = this._createIntroForm();
    this._placeForm = this._createPlaceForm();
    this._serialsForm = this._createSerialsForm();
    this._peopleForm = this._createPeopleForm();

    this._showIntroForm();
    this._loadMovementTypes();
  },

  destruct : function() {
    this._disposeObjects("_introForm", "_placeForm", "_serialsForm", "_peopleForm");
  },

  properties :
  {
    movementTypesUrl :
    {
      check : "String",
      init  : "/movement_types/getTypes"
    },

    registerHandoutUrl :
    {
      check : "String",
      init : "/movements/registerHandout"
    },

    peopleDataUrl :
    {
      check : "String",
      init  : "/people/laptopsNotInHands"
    }
  },

  statics :
  {
    states : { INTRO: 0, PLACE: 1, PEOPLE: 2, SERIALS: 3 },
    modes : { PLACE: 0, SERIALS: 1 }
  },

  members :
  {
    _createIntroForm : function() {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(0));

      var label = new qx.ui.basic.Label(this.tr("Use this form to mark laptops as handed out. For each laptop, a movement will be created, from the current owner to the respective assignee."));
      label.setRich(true);
      vbox.add(label);

      label = new qx.ui.basic.Label(this.tr("Movement type:"));
      label.setPaddingTop(10)
      vbox.add(label);
      vbox.add(this._movementTypeSelector);

      label = new qx.ui.basic.Label(this.tr("Comment:"));
      label.setPaddingTop(10)
      vbox.add(label);
      vbox.add(this._commentField);

      label = new qx.ui.basic.Label(this.tr("Register handout:"));
      label.setPaddingTop(10)
      vbox.add(label);

      var radio = new qx.ui.form.RadioButton(this.tr("By place"));
      radio.setModel(inventario.window.RegisterHandout.modes.PLACE);
      this._modeRadioGroup.add(radio);
      vbox.add(radio);

      radio = new qx.ui.form.RadioButton(this.tr("By laptop serial numbers"));
      radio.setModel(inventario.window.RegisterHandout.modes.SERIALS);
      this._modeRadioGroup.add(radio);
      vbox.add(radio);

      return vbox;
    },

    _createPlaceForm : function() {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(10));

      var label = new qx.ui.basic.Label(this.tr("Select the place where the handout will be registered."));
      vbox.add(label);

      vbox.add(this._placeSelector);
      return vbox;
    },

    _createSerialsForm : function() {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(10));

      var label = new qx.ui.basic.Label(this.tr("Enter the serial numbers of the laptops for which handout should be registered."));
      label.setRich(true);
      vbox.add(label);

      vbox.add(this._serialsTextArea);
      return vbox;
    },

    _createPeopleForm : function() {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(10));

      var label = new qx.ui.basic.Label(this.tr("Entries with a tick will cause a movement to be created for each laptop, to the current assignee of the laptop (shown)."));
      label.setRich(true);
      vbox.add(label);

      var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox());
      vbox.add(hbox);

      var selAll = new qx.ui.form.Button("+");
      var selNone = new qx.ui.form.Button("-");
      selAll.addListener("execute", this._selectAllPeople, this);
      selNone.addListener("execute", this._selectNoPeople, this);
      hbox.add(selAll);
      hbox.add(selNone);

      var scroll = new qx.ui.container.Scroll().set({ width: 300, height:  200 });
      scroll.add(this._peopleBox);
      vbox.add(scroll);

      return vbox;
    },

    _selectAllPeople : function() {
      var children = this._peopleBox.getChildren();
      for (var idx in children)
        children[idx].setValue(true);
    },

    _selectNoPeople : function() {
      var children = this._peopleBox.getChildren();
      for (var idx in children)
        children[idx].setValue(false);
    },

    _getMode : function() {
      var sel = this._modeRadioGroup.getSelection();
      return sel[0].getModel()
    },

    _doRegisterCb : function(remoteData, params) {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);
      this.close();
    },

    _doRegister : function(to_register) {
      var payload = {
        to_register: to_register,
        movement_type: inventario.widget.Form.getInputValue(this._movementTypeSelector),
        comment: this._commentField.getValue()
      };

      var hopts = {};
      hopts["url"] = this.getRegisterHandoutUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._doRegisterCb;
      hopts["data"] = { payload: qx.lang.Json.stringify(payload) };
      inventario.transport.Transport.callRemote(hopts, this);
    },

    _doRegisterPeople : function() {
      var children = this._peopleBox.getChildren();
      var to_register = new Array();
      for (var idx in children) {
        var child = children[idx];
        if (child.getValue())
          to_register.push(child.getUserData("laptop_sn"));
      }

      var confirm_msg = this.trn("Register %1 handout in %2?", "Register %1 handouts in %2?", to_register.length);
      confirm_msg = qx.lang.String.format(confirm_msg, [to_register.length, this._placeSelector.getItemFullLabel()]);
      if (!confirm(confirm_msg))
        return;

      this._doRegister(to_register)
    },

    _doRegisterSerials : function() {
      var confirm_msg = this.tr("Register handout from serial numbers?");
      if (!confirm(confirm_msg))
        return;

      this._doRegister(this._serialsTextArea.getValue())
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

    _loadPeopleCb : function(remoteData, params) {
      this._people = remoteData.items;
      this._showPeopleForm();
    },

    _loadPeople : function() {
      var hopts = {};
      hopts["url"] = this.getPeopleDataUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadPeopleCb;
      hopts["data"] = { place_id : this._placeSelector.getValue() };
      inventario.transport.Transport.callRemote(hopts, this);
    },

    _placeSelectionChanged : function() {
      this._nextButton.setEnabled(this._placeSelector.getValue() != -1);
    },

    _backClicked : function() {
      switch (this._state) {
      case inventario.window.RegisterHandout.states.PLACE:
      case inventario.window.RegisterHandout.states.SERIALS:
        this._showIntroForm();
        break;
      case inventario.window.RegisterHandout.states.PEOPLE:
        this._showPlaceForm();
        break;
      }
    },

    _nextClicked : function() {
      switch (this._state) {
      case inventario.window.RegisterHandout.states.INTRO:
        if (this._getMode() == inventario.window.RegisterHandout.modes.PLACE)
          this._showPlaceForm();
        else
          this._showSerialsForm();
        break;
      case inventario.window.RegisterHandout.states.PLACE:
        this._loadPeople();
        break;
      case inventario.window.RegisterHandout.states.PEOPLE:
        this._doRegisterPeople();
        break;
      case inventario.window.RegisterHandout.states.SERIALS:
        this._doRegisterSerials();
        break;
      }
    },

    /* Remove all elements from main view except the button hbox */
    _clearVbox : function() {
      var children = this.getVbox().getChildren();
      children = children.slice(0, -1);
      for (var idx in children)
        this.getVbox().remove(children[idx]);
    },

    _showIntroForm : function() {
      this._state = inventario.window.RegisterHandout.states.INTRO;
      this._clearVbox();
      this.getVbox().addAt(this._introForm, 0);
      this._nextButton.setEnabled(true);
      this._backButton.setEnabled(false);
    },

    _showPlaceForm : function() {
      this._state = inventario.window.RegisterHandout.states.PLACE;
      this._clearVbox();
      this.getVbox().addAt(this._placeForm, 0);
      this._backButton.setEnabled(true);

      /* to correctly set sensitivity of next button */
      this._placeSelectionChanged();
    },

    _showSerialsForm : function() {
      this._state = inventario.window.RegisterHandout.states.SERIALS;
      this._clearVbox();
      this.getVbox().addAt(this._serialsForm, 0);
      this._nextButton.setEnabled(true);
      this._backButton.setEnabled(true);
    },

    _showPeopleForm : function() {
      this._state = inventario.window.RegisterHandout.states.PEOPLE;
      this._clearVbox();
      this.getVbox().addAt(this._peopleForm, 0);
      this._nextButton.setEnabled(true);
      this._backButton.setEnabled(true);

      // Remove children from box in reverse order to avoid issues with
      // in-place array modification
      var children = this._peopleBox.getChildren();
      for (var i = children.length - 1; i >= 0; i--) {
        var child = children[i];
        this._peopleBox.removeAt(i);
        child.dispose();
      }

      for (var idx in this._people) {
        var person = this._people[idx];
        var checkbox = new qx.ui.form.CheckBox(person[0] + ": " + person[1]);
        checkbox.setUserData("laptop_sn", person[0]);
        checkbox.setValue(true);
        this._peopleBox.add(checkbox);
      }
    }
  }
});
