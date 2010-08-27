
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
// PlaceCreationToolBox.js
// Its supposed to help the system places creation process, to make it as easy as possible.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// 2009
qx.Class.define("inventario.widget.PlaceCreationToolBox",
{
  extend : inventario.window.AbstractWindow,

  construct : function(page) {
    this.base(arguments, page);
  },

  statics :
  {
    /**
     * TODOC
     *
     * @param page {var} TODOC
     * @return {void} 
     */
    launch : function(page)
    {
      var PCToolBox = new inventario.widget.PlaceCreationToolBox(null);
      PCToolBox.setPage(page);
      PCToolBox.setWindowTitle(qx.locale.Manager.tr("Locations ToolBox"));
      PCToolBox.setUsePopup(true);
      PCToolBox.show();
    }
  },

  properties :
  {
    hierarchyWidget :
    {
      check    : "Object",
      nullable : true,
      init     : null
    },

    retrievePlaceUrl :
    {
      check : "String",
      init  : "/schools/createPlace"
    },

    deletePlaceUrl :
    {
      check : "String",
      init  : "/schools/deletePlace"
    },

    retrievePersonUrl :
    {
      check : "String",
      init  : "/schools/createPerson"
    },

    deletePersonUrl :
    {
      check : "String",
      init  : "/schools/deletePerson"
    },

    updatePersonUrl :
    {
      check : "String",
      init  : "/schools/updatePerson"
    }
  },

  members :
  {
    /**
     * TODOC
     *
     * @param data {var} TODOC
     * @param url {var} TODOC
     * @param handle {var} TODOC
     * @return {void} 
     */
    _sendToServer : function(data, url, handle)
    {
      var hopts = {};
      hopts["url"] = url;
      hopts["parametros"] = null;
      hopts["handle"] = handle;
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
    _refreshAfterCreate : function(remoteData, params) {
      this.getHierarchyWidget().reLoadElements();
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _refreshAfterDelete : function(remoteData, params) {
      this.getHierarchyWidget().reLoadParentElements();
    },


    /**
     * TODOC
     *
     * @param layout {var} TODOC
     * @return {void} 
     */
    _doShow : function(layout) {
      this._doShow2(layout);
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    show : function()
    {
      var layout = this._createLayout();
      this._doShow(layout);
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _createLayout : function()
    {
      var container = new qx.ui.container.Composite(new qx.ui.layout.VBox(20));
      var layout = new qx.ui.container.Composite(new qx.ui.layout.HBox(5));

      var hierarchyWidget = new inventario.widget.HierarchyOnDemand();
      hierarchyWidget.setSize(300, 300);
      this.setHierarchyWidget(hierarchyWidget);

      var creationMenu = this._creationMenu();
      var personCreationMenu = this._personCreationMenu();

      layout.add(hierarchyWidget);
      container.add(creationMenu);
      container.add(personCreationMenu);
      layout.add(container);

      return layout;
    },

    /* Add Place Callback */

    /**
     * TODOC
     *
     * @param comboBox {var} TODOC
     * @param customName {var} TODOC
     * @param customType {var} TODOC
     * @return {void} 
     */
    _addPlaceCB : function(comboBox, customName, customType)
    {
      try
      {
        var hierarchy = this.getHierarchyWidget();

        if (!hierarchy.isSubElement())
        {
          var data = {};
          data.parent_place_id = hierarchy.getValue();
          data.place_type = (comboBox == null) ? customType : inventario.widget.Form.getInputValue(comboBox);

          var place_name = "";
          if (customName != null){
            var aux_name  = customName.getValue();
	    if (aux_name != null && aux_name != ""){
	    	place_name = aux_name;
	    }
          }

	  //Not redundant!
          if (place_name.length == 0) {
              place_name = comboBox.getSelection()[0].getLabel();
	  } 

	  if (customType == null && comboBox.getUserData("encoded_value")) {
	    data.place_type = data.place_type.split("_")[1];
	  }

          data.place_name = place_name;

          this._sendToServer(data, this.getRetrievePlaceUrl(), this._refreshAfterCreate);

        } else {
          alert(qx.locale.Manager.tr("The selected item is not a location."));
        }
      } catch(e) {
        alert(e.toString());
      }
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _deletePlaceCB : function()
    {
      var hierarchy = this.getHierarchyWidget();

      if (!hierarchy.isSubElement())
      {
        var data = {};
        data.id = hierarchy.getValue();
        this._sendToServer(data, this.getDeletePlaceUrl(), this._refreshAfterDelete);
      }
      else
      {
        alert(qx.locale.Manager.tr("The selected item is not a City."));
      }
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _creationMenu : function()
    {
      var container = new qx.ui.container.Composite(new qx.ui.layout.Grid());

      /* School creation form */

      var schoolLabel = new qx.ui.basic.Label(qx.locale.Manager.tr("School Number: "));
      var schoolText = new qx.ui.form.TextField();
      var addSchoolButton = new qx.ui.form.Button(qx.locale.Manager.tr("Add School"));

      addSchoolButton.addListener("execute", function(e) {
        this._addPlaceCB(null, schoolText, "school");
      }, this);

      /* Shift Creation form */
      var shiftLabel = new qx.ui.basic.Label(qx.locale.Manager.tr("Shift: "));
      var shiftCombo = new qx.ui.form.SelectBox;

      var shiftData = [
      {
        text     : qx.locale.Manager.tr("Morning Shift"),
        value    : "morning_shift",
        selected : true
      },
      {
        text     : qx.locale.Manager.tr("Afternoon Shift"),
        value    : "afternoon_shift",
        selected : false
      },
      {
        text     : qx.locale.Manager.tr("Full Time"),
        value    : "full_shift",
        selected : false
      } ];

      inventario.widget.Form.loadComboBox(shiftCombo, shiftData, false);
      var addShiftButton = new qx.ui.form.Button(qx.locale.Manager.tr("Add Time"));

      shiftCombo.setUserData("encoded_value", true);
      addShiftButton.addListener("execute", function(e) {
        this._addPlaceCB(shiftCombo, null, null);
      }, this);

      /* Grade Creation form */

      var gradeLabel = new qx.ui.basic.Label(qx.locale.Manager.tr("Grade: "));
      var gradeCombo = new qx.ui.form.SelectBox;

      var gradeData = [
      {
        text     : qx.locale.Manager.tr("First Grade"),
        value    : "first_grade",
        selected : true
      },
      {
        text     : qx.locale.Manager.tr("Second Grade"),
        value    : "second_grade",
        selected : false
      },
      {
        text     : qx.locale.Manager.tr("Third Grade"),
        value    : "third_grade",
        selected : false
      },
      {
        text     : qx.locale.Manager.tr("Fourth Grade"),
        value    : "fourth_grade",
        selected : false
      },
      {
        text     : qx.locale.Manager.tr("Fifth Grade"),
        value    : "fifth_grade",
        selected : false
      },
      {
        text     : qx.locale.Manager.tr("Sixth Grade"),
        value    : "sixth_grade",
        selected : false
      },
      {
        text     : qx.locale.Manager.tr("Special Education"),
        value    : "special",
        selected : false
      } ];

      inventario.widget.Form.loadComboBox(gradeCombo, gradeData, false);
      var addGradeButton = new qx.ui.form.Button(qx.locale.Manager.tr("Add Grade"));

      addGradeButton.addListener("execute", function(e) {
        this._addPlaceCB(gradeCombo, null, null);
      }, this);

      /* Section Creation form */

      var sectionLabel = new qx.ui.basic.Label(qx.locale.Manager.tr("Section: "));
      var sectionCombo = new qx.ui.form.SelectBox;

      var sectionData = [
      {
        text     : qx.locale.Manager.tr("Section: A"),
        value    : "a_section",
        selected : true
      },
      {
        text     : qx.locale.Manager.tr("Section: B"),
        value    : "b_section",
        selected : false
      },
      {
        text     : qx.locale.Manager.tr("Section: C"),
        value    : "c_section",
        selected : false
      } ];

      inventario.widget.Form.loadComboBox(sectionCombo, sectionData, false);
      var sectionText = new qx.ui.form.TextField();
      var addSectionButton = new qx.ui.form.Button(qx.locale.Manager.tr("Add Section:"));

      sectionCombo.setUserData("encoded_value", true);
      addSectionButton.addListener("execute", function(e) {
        this._addPlaceCB(sectionCombo, sectionText, null);
      }, this);

      var deleteButton = new qx.ui.form.Button(qx.locale.Manager.tr("Remove Location"));
      deleteButton.addListener("execute", this._deletePlaceCB, this);

      /* Finally, lets put everything inside the container */

      container.add(schoolLabel,
      {
        row    : 0,
        column : 0
      });

      container.add(schoolText,
      {
        row    : 0,
        column : 1
      });

      container.add(addSchoolButton,
      {
        row    : 0,
        column : 2
      });

      container.add(shiftLabel,
      {
        row    : 1,
        column : 0
      });

      container.add(shiftCombo,
      {
        row    : 1,
        column : 1
      });

      container.add(addShiftButton,
      {
        row    : 1,
        column : 2
      });

      container.add(gradeLabel,
      {
        row    : 2,
        column : 0
      });

      container.add(gradeCombo,
      {
        row    : 2,
        column : 1
      });

      container.add(addGradeButton,
      {
        row    : 2,
        column : 2
      });

      container.add(sectionLabel,
      {
        row    : 3,
        column : 0
      });

      container.add(sectionCombo,
      {
        row    : 3,
        column : 1
      });

      container.add(sectionText,
      {
        row    : 4,
        column : 1
      });

      container.add(addSectionButton,
      {
        row    : 3,
        column : 2
      });

      container.add(deleteButton,
      {
        row    : 5,
        column : 2
      });

      return container;
    },


    /**
     * TODOC
     *
     * @param nameText {var} TODOC
     * @param lastNameText {var} TODOC
     * @param idDocText {var} TODOC
     * @param type {var} TODOC
     * @return {void} 
     */
    _addPersonCB : function(nameText, lastNameText, idDocText, type)
    {
      var hierarchy = this.getHierarchyWidget();

      if (!hierarchy.isSubElement())
      {
        var data = {};
        data.place_id = hierarchy.getValue();
        data.name = nameText.getValue();
        data.lastname = lastNameText.getValue();
        data.id_document = idDocText.getValue();
        data.type = type;

        this._sendToServer(data, this.getRetrievePersonUrl(), this._refreshAfterCreate);
      }
      else
      {
        alert(qx.locale.Manager.tr("The selected item is not a location."));
      }
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _deletePersonCB : function()
    {
      var hierarchy = this.getHierarchyWidget();

      if (hierarchy.isSubElement())
      {
        var element_data = hierarchy.getElementData();
        var msg = qx.locale.Manager.tr("Are you sure you want to delete ") + "\"" + element_data.text + "\"?"

        if (confirm(msg))
        {
          var data = {};
          data.id = hierarchy.getValue();
          this._sendToServer(data, this.getDeletePersonUrl(), this._refreshAfterDelete);
        }
      }
      else
      {
        alert(qx.locale.Manager.tr("The selected item is not a Person."));
      }
    },


    /**
     * TODOC
     *
     * @param nameText {var} TODOC
     * @param lastNameText {var} TODOC
     * @param idDocText {var} TODOC
     * @return {void} 
     */
    _updatePersonCB : function(nameText, lastNameText, idDocText)
    {
      var hierarchy = this.getHierarchyWidget();

      if (hierarchy.isSubElement())
      {
        var element_data = hierarchy.getElementData();
        var new_name = nameText.getValue();
        var new_lastname = lastNameText.getValue();
        var new_idDoc = idDocText.getValue();

        var msg = element_data.text + "\n\n";
        var updated = false;

        var data = {};
        data.id = hierarchy.getValue();

        if (new_name != null && new_name != "")
        {
          msg += qx.locale.Manager.tr("Update name to: ") + "\"" + new_name + "\"?\n";
          data.name = new_name;
          updated = true;
        }

        if (new_lastname != null && new_lastname != "")
        {
          msg += qx.locale.Manager.tr("Update lastname to: ") + "\"" + new_lastname + "\"?\n";
          data.lastname = new_lastname;
          updated = true;
        }

        if (new_idDoc != null && new_idDoc != "")
        {
          msg += qx.locale.Manager.tr("Update document number to: ") + "\"" + new_idDoc + "\"?\n";
          data.id_document = new_idDoc;
          updated = true;
        }

        if (!updated){
          alert(qx.locale.Manager.tr("Nothing to be updated."));
          return;
        }
        else
        {
          if (confirm(msg))
          {
            this._sendToServer(data, this.getUpdatePersonUrl(), this._refreshAfterDelete);
          }
        }

      }
      else
      {
        alert(qx.locale.Manager.tr("The selected item is not a Person."));
      }
    },


    /**
     * TODOC
     *
     * @param checkBox {var} TODOC
     * @param value {var} TODOC
     * @return {void} 
     */
    _changeChecked : function(checkBox, value)
    {
      var hierarchy = this.getHierarchyWidget();
      var tags = hierarchy.getSubElementTags();

      if (checkBox.getValue()) {
        tags.push(value);
      }
      else
      {
        var index = tags.indexOf(value);
        tags.splice(index, 1);
      }
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    _personCreationMenu : function()
    {
      var container = new qx.ui.container.Composite(new qx.ui.layout.Grid());

      var nameLabel = new qx.ui.basic.Label(qx.locale.Manager.tr("Name: "));
      var nameText = new qx.ui.form.TextField();

      var lastNameLabel = new qx.ui.basic.Label(qx.locale.Manager.tr("Last name: "));
      var lastNameText = new qx.ui.form.TextField();

      var idDocLabel = new qx.ui.basic.Label(qx.locale.Manager.tr("National ID "));
      var idDocText = new qx.ui.form.TextField();

      var addStudentButton = new qx.ui.form.Button(qx.locale.Manager.tr("Add Student"));

      addStudentButton.addListener("execute", function() {
        this._addPersonCB(nameText, lastNameText, idDocText, "student");
      }, this);

      var addTeacherButton = new qx.ui.form.Button(qx.locale.Manager.tr("Add Teacher"));

      addTeacherButton.addListener("execute", function() {
        this._addPersonCB(nameText, lastNameText, idDocText, "teacher");
      }, this);

      var deleteButton = new qx.ui.form.Button(qx.locale.Manager.tr("Delete Person"));
      deleteButton.addListener("execute", this._deletePersonCB, this);

      var updateButton = new qx.ui.form.Button(qx.locale.Manager.tr("Update Person"));

      updateButton.addListener("execute", function() {
        this._updatePersonCB(nameText, lastNameText, idDocText);
      }, this);

      var teacherChecked = new qx.ui.form.CheckBox(qx.locale.Manager.tr("Show Teachers: "));

      teacherChecked.addListener("changeValue", function() {
        this._changeChecked(teacherChecked, "teacher");
      }, this);

      var studentChecked = new qx.ui.form.CheckBox(qx.locale.Manager.tr("Show student : "));

      studentChecked.addListener("changeValue", function() {
        this._changeChecked(studentChecked, "student");
      }, this);

      container.add(nameLabel,
      {
        row    : 0,
        column : 0
      });

      container.add(nameText,
      {
        row    : 0,
        column : 1
      });

      container.add(lastNameLabel,
      {
        row    : 1,
        column : 0
      });

      container.add(lastNameText,
      {
        row    : 1,
        column : 1
      });

      container.add(idDocLabel,
      {
        row    : 2,
        column : 0
      });

      container.add(idDocText,
      {
        row    : 2,
        column : 1
      });

      container.add(addStudentButton,
      {
        row    : 3,
        column : 0
      });

      container.add(addTeacherButton,
      {
        row    : 3,
        column : 1
      });

      container.add(deleteButton,
      {
        row    : 3,
        column : 2
      });

      container.add(teacherChecked,
      {
        row    : 4,
        column : 1
      });

      container.add(studentChecked,
      {
        row    : 4,
        column : 0
      });

      container.add(updateButton,
      {
        row    : 4,
        column : 2
      });

      return container;
    }
  }
});
