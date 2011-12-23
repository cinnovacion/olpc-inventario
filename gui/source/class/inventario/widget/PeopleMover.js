
//     Copyright Daniel Drake 2011
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
// A dialog to move selected people from one place to another.

qx.Class.define("inventario.widget.PeopleMover",
{
  extend : inventario.window.AbstractWindow,

  construct : function(page)
  {
    this.base(arguments, page, qx.locale.Manager.tr("Move people"));
    this._state = inventario.widget.PeopleMover.states.PLACES
    this._people = []

    this.getVbox().getLayout().setSpacing(10);

    /* Tree selectors for source and destination places */
    var opts = { width: 360, height: 120 };
    this._srcPlace = new inventario.widget.HierarchyOnDemand(null, opts);
    this._dstPlace = new inventario.widget.HierarchyOnDemand(null, opts);
    this._srcPlace.getTreeWidget().addListener("changeSelection", this._treeSelectionChanged, this);
    this._dstPlace.getTreeWidget().addListener("changeSelection", this._treeSelectionChanged, this);

    /* VBox to load list of student checkboxes */
    this._studentsBox = new qx.ui.container.Composite(new qx.ui.layout.VBox());

    this._addComment = new qx.ui.form.CheckBox(qx.locale.Manager.tr("Add comment to person notes"));

    var hbox = new qx.ui.container.Composite(new qx.ui.layout.HBox());
    this.getVbox().add(hbox)

    this._backButton = new qx.ui.form.Button(qx.locale.Manager.tr("Back"));
    this._backButton.addListener("execute", this._backClicked, this);
    hbox.add(this._backButton);

    this._nextButton = new qx.ui.form.Button();
    this._nextButton.addListener("execute", this._nextClicked, this);
    hbox.add(this._nextButton);

    this._placeSelector = this._createPlaceSelector();
    this._peopleSelector = this._createPeopleSelector();
    this._showPlaces(); /* initial state */
  },

  statics :
  {
    launch : function(page)
    {
      var mover = new inventario.widget.PeopleMover(page);
      mover.open();
    },

    states : { PLACES: 0, PEOPLE: 1 }
  },

  properties :
  {
    listPeopleUrl :
    {
      check : "String",
      init : "/people/listPeople"
    },

    movePeopleUrl :
    {
      check : "String",
      init : "/people/movePeople"
    }
  },

  members :
  {
    _createPlaceSelector : function() {
      var grid = new qx.ui.layout.Grid();
      var container = new qx.ui.container.Composite(grid);

      var label = new qx.ui.basic.Label(qx.locale.Manager.tr("Select the source place from where people are to be moved, and the destination where they will be transferred to. On the next screen you can select exactly which people from the source are to be moved."));
      label.setRich(true);
      container.add(label, {row: 0, column: 0, colSpan: 2});

      label = new qx.ui.basic.Label(qx.locale.Manager.tr("Move people from:"));
      container.add(label, {row: 1, column: 0});
      label = new qx.ui.basic.Label(qx.locale.Manager.tr("Move people to:"));
      container.add(label, {row: 2, column: 0});

      container.add(this._srcPlace, {row: 1, column: 1});
      container.add(this._dstPlace, {row: 2, column: 1});
      return container;
    },

    _createPeopleSelector : function() {
      var vbox = new qx.ui.container.Composite(new qx.ui.layout.VBox(10));

      var label = new qx.ui.basic.Label(qx.locale.Manager.tr("Select the people to be moved from the list below."));
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
      scroll.add(this._studentsBox);
      vbox.add(scroll);

      vbox.add(this._addComment);
      return vbox;
    },

    _selectAllPeople : function() {
      var children = this._studentsBox.getChildren();
      for (var idx in children) {
        children[idx].setValue(true);
      }
    },

    _selectNoPeople : function() {
      var children = this._studentsBox.getChildren();
      for (var idx in children) {
        children[idx].setValue(false);
      }
    },

    _backClicked : function() {
      this._showPlaces();
    },

    _nextClicked : function() {
      if (this._state == inventario.widget.PeopleMover.states.PLACES)
        this._loadPeople();
      else
        this._doMove();
    },

    _treeSelectionChanged : function() {
      /* Only make "Next" button sensitive if two different places have been
       * selected. */
      var src_id = this._srcPlace.getValue();
      var dst_id = this._dstPlace.getValue();
      var sensitive = src_id != -1 && dst_id != -1 && src_id != dst_id;
      this._nextButton.setEnabled(sensitive);
    },

    _loadPeopleCb : function(remoteData, params) {
      this._people = remoteData.list
      this._showPeople()
    },

    _loadPeople : function() {
      var hopts = {};
      hopts["url"] = this.getListPeopleUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._loadPeopleCb;
      hopts["data"] = { id : this._srcPlace.getValue() };
      inventario.transport.Transport.callRemote(hopts, this);
    },

    _doMoveCb : function(remoteData, params) {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);
      this.close();
    },

    _doMove : function() {
      var children = this._studentsBox.getChildren();
      var to_move = new Array();
      for (var idx in children) {
        var child = children[idx];
        if (child.getValue())
          to_move.push(child.getUserData("id"));
      }

      var confirm_msg = qx.locale.Manager.trn("Move %1 person to %2?", "Move %1 people to %2?");
      confirm_msg = qx.lang.String.format(confirm_msg, [to_move.length, this._dstPlace.getItemFullLabel()]);
      if (!confirm(confirm_msg))
        return;

      var payload = {
        people_ids: to_move,
        src_place_id: this._srcPlace.getValue(),
        dst_place_id: this._dstPlace.getValue()
      };

      if (this._addComment.getValue())
        payload["add_comment"] = 1;

      var hopts = {};
      hopts["url"] = this.getMovePeopleUrl();
      hopts["parametros"] = null;
      hopts["handle"] = this._doMoveCb;
      hopts["data"] = { payload: qx.lang.Json.stringify(payload) };
      inventario.transport.Transport.callRemote(hopts, this);
    },

    /* Remove all elements from main view except the button hbox */
    _clearVbox : function() {
      var children = this.getVbox().getChildren();
      children = children.slice(0, -1);
      for (var idx in children) {
        this.getVbox().remove(children[idx]);
      }
    },

    _showPlaces : function() {
      this._state = inventario.widget.PeopleMover.states.PLACES;
      this._clearVbox();
      this.getVbox().addAt(this._placeSelector, 0);
      this._nextButton.setLabel(qx.locale.Manager.tr("Next"));
      this._backButton.setEnabled(false);

      /* to correctly set sensitivity of next button */
      this._treeSelectionChanged();
    },

    _showPeople : function() {
      this._state = inventario.widget.PeopleMover.states.PEOPLE;
      this._clearVbox();
      this.getVbox().addAt(this._peopleSelector, 0);
      this._backButton.setEnabled(true);
      this._nextButton.setLabel(qx.locale.Manager.tr("Move people"));
      this._nextButton.setEnabled(true);
      this._addComment.setValue(true);

      this._studentsBox.removeAll();
      for (var idx in this._people) {
        var student = this._people[idx];
        var checkbox = new qx.ui.form.CheckBox(student.text);
        checkbox.setUserData("id", student.id);
        checkbox.setValue(true);
        this._studentsBox.add(checkbox);
      }
    }
  }
});
