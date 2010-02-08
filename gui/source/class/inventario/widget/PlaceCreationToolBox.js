
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

  /*
       * CONSTRUCTOR
       */

  construct : function(page) {
    this.base(arguments, page);
  },

  /*
       * STATICS
       */

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
      PCToolBox.setWindowTitle("Localidades Tool Box");
      PCToolBox.setUsePopup(true);
      PCToolBox.show();
    }
  },

  /*
       * PROPERTIES
       */

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

  /*
       * MEMBERS
       */

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

          var place_name = (customName == null) ? "" : customName.getValue().toString();

          if (place_name.length == 0) {
            place_name = comboBox.getValue();
          }

          data.place_name = place_name;

          this._sendToServer(data, this.getRetrievePlaceUrl(), this._refreshAfterCreate);
        }
        else
        {
          alert("El elemento seleccionado no es una Localidad.");
        }
      }
      catch(e)
      {
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
        alert("El elemento seleccionado no es una Localidad.");
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

      var schoolLabel = new qx.ui.basic.Label("Escuela Numero: ");
      var schoolText = new qx.ui.form.TextField();
      var addSchoolButton = new qx.ui.form.Button("Agregar Escuela");

      addSchoolButton.addListener("execute", function(e) {
        this._addPlaceCB(null, schoolText, "school");
      }, this);

      /* Shift Creation form */

      var shiftLabel = new qx.ui.basic.Label("Turno: ");
      var shiftCombo = new qx.ui.form.SelectBox;

      var shiftData = [
      {
        text     : "Turno Mañana",
        value    : "shift",
        selected : true
      },
      {
        text     : "Turno Tarde",
        value    : "shift",
        selected : false
      },
      {
        text     : "Turno Completo",
        value    : "shift",
        selected : false
      } ];

      inventario.widget.Form.loadComboBox(shiftCombo, shiftData, false);
      var addShiftButton = new qx.ui.form.Button("Agregar Turno");

      addShiftButton.addListener("execute", function(e) {
        this._addPlaceCB(shiftCombo, null, null);
      }, this);

      /* Grade Creation form */

      var gradeLabel = new qx.ui.basic.Label("Grado: ");
      var gradeCombo = new qx.ui.form.SelectBox;

      var gradeData = [
      {
        text     : "Primer Grado",
        value    : "first_grade",
        selected : true
      },
      {
        text     : "Segundo Grado",
        value    : "second_grade",
        selected : false
      },
      {
        text     : "Tercer Grado",
        value    : "third_grade",
        selected : false
      },
      {
        text     : "Cuarto Grado",
        value    : "fourth_grade",
        selected : false
      },
      {
        text     : "Quinto Grado",
        value    : "fifth_grade",
        selected : false
      },
      {
        text     : "Sexto Grado",
        value    : "sixth_grade",
        selected : false
      },
      {
        text     : "Educacion Especial",
        value    : "special",
        selected : false
      } ];

      inventario.widget.Form.loadComboBox(gradeCombo, gradeData, false);
      var addGradeButton = new qx.ui.form.Button("Agregar Grado");

      addGradeButton.addListener("execute", function(e) {
        this._addPlaceCB(gradeCombo, null, null);
      }, this);

      /* Section Creation form */

      var sectionLabel = new qx.ui.basic.Label("Seccion: ");
      var sectionCombo = new qx.ui.form.SelectBox;

      var sectionData = [
      {
        text     : "Seccion A",
        value    : "section",
        selected : true
      },
      {
        text     : "Seccion B",
        value    : "section",
        selected : false
      },
      {
        text     : "Seccion C",
        value    : "section",
        selected : false
      } ];

      inventario.widget.Form.loadComboBox(sectionCombo, sectionData, false);
      var sectionText = new qx.ui.form.TextField();
      var addSectionButton = new qx.ui.form.Button("Agregar Seccion");

      addSectionButton.addListener("execute", function(e) {
        this._addPlaceCB(sectionCombo, sectionText, null);
      }, this);

      var deleteButton = new qx.ui.form.Button("Eliminar Localidad");
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
        alert("El elemento seleccionado no es una localidad.");
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
        var data = {};
        data.id = hierarchy.getValue();
        this._sendToServer(data, this.getDeletePersonUrl(), this._refreshAfterDelete);
      }
      else
      {
        alert("El elemento seleccionado no es una Persona.");
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

        var msg = "Actualizar a " + element_data.text;
        msg += " con el nombre " + "\"" + new_name + "\"";
        msg += ", el apellido " + "\"" + new_lastname + "\"";
        msg += " y documento numero " + "\"" + new_idDoc + "\"?";
        msg += " Los campos vacios no sean actualizados.";

        if (confirm(msg))
        {
          var data = {};
          data.id = hierarchy.getValue();
          data.name = new_name;
          data.lastname = new_lastname;
          data.id_document = new_idDoc;
          this._sendToServer(data, this.getUpdatePersonUrl(), this._refreshAfterDelete);
        }
      }
      else
      {
        alert("El elemento seleccionado no es una Persona.");
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

      if (checkBox.isChecked()) {
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

      var nameLabel = new qx.ui.basic.Label("Nombre: ");
      var nameText = new qx.ui.form.TextField();

      var lastNameLabel = new qx.ui.basic.Label("Apellido: ");
      var lastNameText = new qx.ui.form.TextField();

      var idDocLabel = new qx.ui.basic.Label("Cedula Numero: ");
      var idDocText = new qx.ui.form.TextField();

      var addStudentButton = new qx.ui.form.Button("Agregar Alumno");

      addStudentButton.addListener("execute", function() {
        this._addPersonCB(nameText, lastNameText, idDocText, "student");
      }, this);

      var addTeacherButton = new qx.ui.form.Button("Agregar Maestro");

      addTeacherButton.addListener("execute", function() {
        this._addPersonCB(nameText, lastNameText, idDocText, "teacher");
      }, this);

      var deleteButton = new qx.ui.form.Button("Eliminar Persona");
      deleteButton.addListener("execute", this._deletePersonCB, this);

      var updateButton = new qx.ui.form.Button("Actualizar Persona");

      updateButton.addListener("execute", function() {
        this._updatePersonCB(nameText, lastNameText, idDocText);
      }, this);

      var teacherChecked = new qx.ui.form.CheckBox("Mostrar Maestros: ");

      teacherChecked.addListener("changeChecked", function() {
        this._changeChecked(teacherChecked, "teacher");
      }, this);

      var studentChecked = new qx.ui.form.CheckBox("Mostrar Alumnos : ");

      studentChecked.addListener("changeChecked", function() {
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