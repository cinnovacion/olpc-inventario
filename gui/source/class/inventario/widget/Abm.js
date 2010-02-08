
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
// Libreria:  Abm.js
// fecha: 2006-10-18
// autor: Raul Gutierrez S. - rgs@fuzzylogic.com.py
// objeto generico para actualizacion de entidades
qx.Class.define("inventario.widget.Abm",
{
  extend : inventario.widget.PageNavigatorAbstract,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function(page, oMethods)
  {
    // llamar al constructor del padre
    inventario.widget.PageNavigatorAbstract.call(this, page, oMethods.list_url);

    // metodos en el servidor (XML-RPC... )
    try
    {
      this.add_url = oMethods.add_url;
      this.delete_url = oMethods.delete_url;
      this.save_url = oMethods.save_url;
    }
    catch(e)
    {
      inventario.window.Mensaje.mensaje("Falta un parametro en el hash de urls! " + e);
    }
  },




  /*
    *****************************************************************************
       PROPERTIES
    *****************************************************************************
    */

  properties :
  {
    addTitle :
    {
      check : "String",
      init  : "Agregar"
    },

    modifyTitle :
    {
      check : "String",
      init  : "Agregar"
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
     * addButtons() :  botones de accion sobre el ABM
     *
     * @return {qx.ui.layout.VerticalBox} TODOC
     */
    addButtons : function()
    {
      var hbox = new qx.ui.layout.HorizontalBoxLayout;
      hbox.setDimension("auto", "auto");

      var bDelete = new qx.ui.form.Button("Eliminar", "icon/16/no.png");
      bDelete.addListener("execute", this._deleteRows, this);
      hbox.add(bDelete);

      var bModify = new qx.ui.form.Button("Modificar", "icon/16/apps/accessories-text-editor.png");

      bModify.addListener("execute", function(e)
      {
        var v = this._getSelected(false);
        if (v.length > 0) this._addRow(v[0]);
      },
      this);

      hbox.add(bModify);

      var bAdd = new qx.ui.form.Button("Agregar", "icon/16/actions/dialog-ok.png");

      bAdd.addListener("execute", function(e) {
        this._addRow(false);
      }, this);

      hbox.add(bAdd);

      return hbox;
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _deleteRows : function()
    {
      var ids = this._getSelected(true);  // buscar filas seleccionadas

      // confirmar borrados
      if (ids.length > 0 && confirm("Eliminar elementos seleccionados"))
      {
        var payload = qx.util.Json.stringify(ids);
        if (this.debug) inventario.window.Mensaje.mensaje("_deleteRows() " + payload);

        var data = { payload : payload };
        var url = this.delete_url;

        inventario.transport.Transport.callRemote(
        {
          url        : url,
          parametros : null,
          handle     : this._deleteRowsResp,
          data       : data
        },
        this);
      }
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} 
     */
    _deleteRowsResp : function(remoteData, handleParams)
    {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);
      this.show();
    },


    /**
     * _addRow(): agregar un nuevo elemento
     *
     * @param editRow {var} si es >=0 es un id de un objeto que se va editar
     * @return {void} void
     *   
     *     FIXME : no deberia ser privada!
     */
    _addRow : function(editRow)
    {
      var data = {};

      if (editRow) {
        data = { id : editRow };
      }

      var url = this.add_url;

      inventario.transport.Transport.callRemote(
      {
        url        : url,
        parametros : null,
        handle     : this._addRowResp,
        data       : data
      },
      this);
    },


    /**
     * _addRowResp(): Recibe los datos acerca del form que se debe crear para el nuevo objeto que se va a crear
     *
     * @param remoteData {var} msg del servidor
     * @param handleParams {var} TODOC
     * @return {void} void
     *   
     *      Aca hay que usar un GroupBox.....
     */
    _addRowResp : function(remoteData, handleParams)
    {
      var datos = remoteData["fields"];
      var len = datos.length;
      var editing = false;
      var remote_id = 0;
      var fields = new Array();
      var gl = new qx.ui.layout.GridLayout;

      this.getPage().removeAll();  // limpiar ventana (creo que estoy no implica free()... asi que,tal vez, tenemos un leak)

      gl.setLocation(0, 0);
      gl.setDimension("auto", "auto");
      gl.setBorder("outset");
      gl.setPadding(8);
      gl.setColumnCount(2);
      gl.setRowCount(len);

      gl.setColumnWidth(0, 150);
      gl.setColumnWidth(1, 200);

      gl.setColumnHorizontalAlignment(0, "left");
      gl.setColumnVerticalAlignment(0, "middle");

      gl.setCellPaddingTop(2);
      gl.setCellPaddingRight(3);
      gl.setCellPaddingBottom(2);
      gl.setCellPaddingLeft(3);

      if (remoteData["id"])
      {
        editing = true;
        remote_id = remoteData["id"];
      }

      this.getPage().add(gl);

      for (var i=0; i<len; i++)
      {
        var input = null;
        var label = new qx.ui.basic.Label(datos[i].label);

        gl.setRowHeight(i, 24);

        try
        {
          switch(datos[i].datatype)
          {
            case "textfield":
              input = new qx.ui.form.TextField(editing ? datos[i].value : "");
              break;

            case "passwordfield":
              input = new qx.ui.form.PasswordField();
              break;

            case "combobox":
              input = new qx.ui.form.SelectBox;
              var options = datos[i].options;
              inventario.widget.Form.loadComboBox(input, options, true);

              if (datos[i].auto_complete_url) {
                input.setAutocomplete(true, datos[i].auto_complete_url);
              }

              break;

            default:
              inventario.window.Mensaje.mensaje(datos[i].datatype);
          }

          // guardar esto p/ el hash de ida osino nos basamos en las posiciones!
          // datos[i].fieldName;
          /*
                     * TODO: validaciones
                     * datos[i].required;
                     * datos[i].validation;
                     */

          gl.add(label, 0, i);
          gl.add(input, 1, i);
          fields.push(input);
        }
        catch(e)
        {
          inventario.window.Mensaje.mensaje("Problema al agregar el elemento num " + i + " de tipo " + datos[i].datatype + " con label " + datos[i].label + ". Excecpion: " + e);
        }
      }

      // boton p/ agregar/guardar cambios
      var hbox = new qx.ui.layout.HorizontalBoxLayout();
      hbox.setDimension("auto", "auto");

      hbox.set(
      {
        bottom : 10,
        left   : 400
      });

      var bCancel = new qx.ui.form.Button("Cancelar", "icon/16/no.png");
      bCancel.addListener("execute", this.show, this);
      hbox.add(bCancel);

      // usar editing p/ establecer tooltip a "Guardar" o "Agregar"
      var bSave = new qx.ui.form.Button("Guardar", "icon/16/actions/dialog-ok.png");

      bSave.addListener("execute", function(e) {
        this._saveData(editing, fields, remote_id);
      }, this);

      hbox.add(bSave);

      this.getPage().add(hbox);
    },


    /**
     * _saveData(): enviar datos p/ que se cree el nuevo objeto en el servidor (o se guarde la edicion
     *
     * @param editing {var} editando o creando?
     * @param fields {var} TODOC
     * @param id {var} en caso de que estemos editando
     * @return {void} void
     */
    _saveData : function(editing, fields, id)
    {
      var data = {};
      data["fields"] = new Array();

      try
      {
        for (var i=0; i<fields.length; i++)
        {
          var v = inventario.widget.Form.getInputValue(fields[i]);
          data["fields"].push(v);
        }

        if (editing) {
          data["id"] = id;
        }

        var payload = qx.util.Json.stringify(data);

        if (this.debug) {
          inventario.window.Mensaje.mensaje("Enviando " + payload);
        }

        var data = { payload : payload };
        var url = this.save_url;

        inventario.transport.Transport.callRemote(
        {
          url        : url,
          parametros : null,
          handle     : this._saveDataResp,
          data       : data
        },
        this);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje(e);
      }
    },


    /**
     * _saveDataResp()
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} void
     */
    _saveDataResp : function(remoteData, handleParams)
    {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);

      if (confirm("Volver al Listado?")) {
        this.show();
      }
    }
  }
});
