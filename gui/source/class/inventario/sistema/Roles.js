
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
// Roles.js
// fecha: 2007-08-06
// autor: Raul Gutierrez S. - rgs@rieder.net.py
//
// ABM de roles
qx.Class.define("inventario.sistema.Roles",
{
  extend : qx.core.Object,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function(oMethods)
  {
    // metodos en el servidor
    try
    {
      this.setListUrl(oMethods.list_url);
      this.setDeleteUrl(oMethods.delete_url);
      this.setSaveUrl(oMethods.save_url);
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
    page      : { check : "Object" },
    listUrl   : { check : "String" },
    addUrl    : { check : "String" },
    deleteUrl : { check : "String" },
    saveUrl   : { check : "String" },
    tree      : { check : "Object" },
    arbol     : { check : "Object" }
  },




  /*
    *****************************************************************************
       MEMBERS
    *****************************************************************************
    */

  members :
  {
    /**
     * show(): estamos al aire
     *
     * @return {void} void
     */
    show : function()
    {
      this.getPage().removeAll();

      var url = this.getListUrl();

      inventario.transport.Transport.callRemote(
      {
        url        : url,
        parametros : null,
        handle     : this._showResp,
        data       : {}
      },
      this);
    },


    /**
     * _showResp(): cargar info
     *
     * @param remoteData {var} datos
     * @param handleParams {var} TODOC
     * @return {void} void
     */
    _showResp : function(remoteData, handleParams)
    {
      var vbox = new qx.ui.layout.VerticalBoxLayout;
      var hbox = new qx.ui.layout.HorizontalBoxLayout;

      vbox.setWidth("100%");
      vbox.setHeight("100%");

      hbox.setDimension("100%", "70%");

      /* Lista de Roles */

      var fs = new qx.ui.groupbox.GroupBox("Roles");
      fs.setDimension("50%", "100%");

      var vData = [
      {
        titulo   : "Perfil",
        width    : 200,
        editable : false,
        renderer : inventario.qooxdoo.ListDataCellRenderer
      } ];

      var table = inventario.widget.Table.createTable(vData, "100%", "100%");
      inventario.widget.Table.addRows(table, remoteData["roles"], -1);

      table.getSelectionModel().setSelectionMode(qx.ui.table.selection.Model.SINGLE_SELECTION);
      fs.add(table);
      hbox.add(fs);

      /* Arbol de Menues */

      var fs = new qx.ui.groupbox.GroupBox("Permisos");
      fs.setDimension("50%", "100%");
      var trs = qx.ui.tree.TreeRowStructure.getInstance().standard("Menues");
      var t = new qx.ui.tree.Tree(trs);

      with (t)
      {
        setBorder("inset");
        setOverflow("scrollY");

        // setHeight(null);
        setHeight("100%");
        setWidth("100%");
      }

      fs.add(t);
      hbox.add(fs);
      this.setTree(t);

      /*
             * cargar arbol : esto habria que generalizar.. se va a usar varias veces
             *
             */

      var arbol = this._loadTree(remoteData["menus"], t);
      this.setArbol(arbol);

      /* cargar configuracion del rol seleccionado.value */

      table.getSelectionModel().addListener("changeSelection", function(e)
      {
        var seleccionado = inventario.widget.Table.getSelected2(table, [ 0 ], false)[0];

        try
        {
          var url = "/administrador/parametricas/roles/get_submenus";
          var data = { id : seleccionado.value };

          inventario.transport.Transport.callRemote(
          {
            url        : url,
            parametros : t,
            handle     : this._updateTreeRemote,
            data       : data
          },
          this);
        }
        catch(e)
        {
          inventario.window.Mensaje.mensaje("cargar perfil " + e);
        }
      },
      this);

      vbox.add(hbox);

      /* label para nuevo rol */

      var hbox = new qx.ui.layout.HorizontalBoxLayout;
      hbox.setDimension("100%", "15%");
      var label1 = new qx.ui.basic.Atom("Nuevo Rol: ");
      hbox.add(label1);
      var rolNameInput = new qx.ui.form.TextField;
      hbox.add(rolNameInput);

      vbox.add(hbox);

      /* Botones p/ guardar_cambios, eliminar, agregar */

      var hbox = new qx.ui.layout.HorizontalBoxLayout;
      hbox.setDimension("100%", "15%");

      var bGuardar = new qx.ui.form.Button("Guardar Cambios");
      hbox.add(bGuardar);

      bGuardar.addListener("execute", function(e)
      {
        var seleccionado = inventario.widget.Table.getSelected2(table, [ 0 ], false)[0];

        if (seleccionado && parseInt(seleccionado.value) > 0) {
          this._saveChanges(seleccionado.value, t);
        } else {
          inventario.window.Mensaje.mensaje("Debe seleccionar un Perfil");
        }
      },
      this);

      var bAgregar = new qx.ui.form.Button("Agregar Rol");
      hbox.add(bAgregar);

      bAgregar.addListener("execute", function(e)
      {
        if (rolNameInput && rolNameInput.getValue() && rolNameInput.getValue() != "") {
          this._addRole(rolNameInput.getValue(), t, table);
        } else {
          inventario.window.Mensaje.mensaje("Nombre de Perfil invalido");
        }
      },
      this);

      var bEliminar = new qx.ui.form.Button("Eliminar Rol");
      hbox.add(bEliminar);

      bEliminar.addListener("execute", function(e)
      {
        var seleccionado = inventario.widget.Table.getSelected2(table, [ 0 ], false)[0];

        if (seleccionado && parseInt(seleccionado.value) > 0) {
          this._deleteRole(seleccionado.value, table);
        } else {
          inventario.window.Mensaje.mensaje("Debe seleccionar un perfil");
        }
      },
      this);

      vbox.add(hbox);

      this.getPage().add(vbox);
    },


    /**
     * _saveChanges():
     *
     * @param role_id {var} TODOC
     * @param tree {var} TODOC
     * @return {void} void
     */
    _saveChanges : function(role_id, tree)
    {
      var config_arbol = this._getTreeConfig(this.getArbol());

      var data =
      {
        role_id : role_id,
        arbol   : qx.util.Json.stringify(config_arbol)
      };

      var url = this.getSaveUrl();

      try
      {
        inventario.transport.Transport.callRemote(
        {
          url        : url,
          parametros : null,
          handle     : this._saveChangesResp,
          data       : data
        },
        this);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje("Error al guardar cambios " + e);
      }
    },


    /**
     * _saveChangesResp():
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} void
     */
    _saveChangesResp : function(remoteData, handleParams) {
      inventario.window.Mensaje.mensaje("Se guardaron sus cambios");
    },


    /**
     * _addRole():
     *
     * @param title {var} nombre del rol
     * @param tree {var} arbol de submenus
     * @param table {qx.ui.table.Table} TODOC
     * @return {void} void
     */
    _addRole : function(title, tree, table)
    {
      var config_arbol = this._getTreeConfig(this.getArbol());

      var data =
      {
        title : title,
        arbol : qx.util.Json.stringify(config_arbol)
      };

      var url = this.getSaveUrl();

      inventario.transport.Transport.callRemote(
      {
        url        : url,
        parametros : table,
        handle     : this._addRoleResp,
        data       : data
      },
      this);
    },


    /**
     * _addRoleResp():
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} void
     */
    _addRoleResp : function(remoteData, handleParams)
    {
      var table = handleParams;

      var f = function()
      {

        /* actualizar tablas de perfiles y establecer ese coo seleccionado */

        inventario.widget.Table.emptyTable(table);
        inventario.widget.Table.addRows(table, remoteData["roles"], -1);
      };

      inventario.window.Mensaje.mensaje("Se agrego el nuevo perfil", f, this);
    },


    /**
     * _deleteRole():
     *
     * @param role_id {var} TODOC
     * @param table {var} TODOC
     * @return {void} void
     */
    _deleteRole : function(role_id, table)
    {
      var url = this.getDeleteUrl();
      var data = { id : role_id };

      inventario.transport.Transport.callRemote(
      {
        url        : url,
        parametros : table,
        handle     : this._deleteRoleResp,
        data       : data
      },
      this);
    },


    /**
     * _deleteRoleResp():
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} void
     */
    _deleteRoleResp : function(remoteData, handleParams)
    {
      var table = handleParams;
      inventario.widget.Table.emptyTable(table);
      inventario.widget.Table.addRows(table, remoteData["roles"], -1);
    },


    /**
     * _loadTree():
     *
     * @param branch {var} TODOC
     * @param rootNode {var} TODOC
     * @return {var} void
     */
    _loadTree : function(branch, rootNode)
    {
      var hashRet = {};
      hashRet["node"] = null;
      var node = branch["node"];
      var childs = branch["childs"];
      var te2 = null;

      if (node)
      {
        var trs = qx.ui.tree.TreeRowStructure.getInstance().newRow();
        var checkbox = new qx.ui.form.CheckBox("");
        checkbox.setPadding(0, 0);
        checkbox.setUserData("pk_id", node["id"]);
        trs.addObject(checkbox, false);
        trs.addLabel(node["descripcion"]);
        te2 = new qx.ui.tree.TreeFolder(trs);
        rootNode.add(te2);

        hashRet["node"] =
        {
          checkbox : checkbox,
          id       : node["id"],
          type     : node["type"]
        };
      }

      if (te2) {
        rootNode = te2;
      }

      hashRet["childs"] = new Array();

      if (childs && childs.length > 0)
      {
        var len2 = childs.length;

        for (var j=0; j<len2; j++)
        {
          var sub_menu = childs[j];
          var n = this._loadTree(sub_menu, rootNode);
          hashRet["childs"].push(n);
        }
      }

      return hashRet;
    },


    /**
     * TODOC
     *
     * @param remoteData {var} TODOC
     * @param handleParams {var} TODOC
     * @return {void} 
     */
    _updateTreeRemote : function(remoteData, handleParams) {
      this._updateTree(this.getArbol(), remoteData["menus"]);
    },


    /**
     * TODOC
     *
     * @param nodo {var} TODOC
     * @param rama {var} TODOC
     * @return {void} 
     */
    _updateTree : function(nodo, rama)
    {
      var hijos = nodo["childs"];
      var len = hijos.length;

      if (nodo["node"])
      {
        var menuCheckBox = nodo["node"]["checkbox"];
        var checked = false;

        if (rama["node"]["selected"]) {
          checked = true;
        }

        menuCheckBox.setValue(checked);
      }

      /* buscar la rama correspondiente */

      var len2 = rama["childs"].length;

      for (var i=0; i<len; i++)
      {
        for (var j=0; j<len2; j++)
        {
          var id_a = hijos[i]["node"]["id"];
          var id_b = rama["childs"][j]["node"]["id"];

          if (parseInt(id_a) == parseInt(id_b))
          {
            this._updateTree(hijos[i], rama["childs"][j]);
            break;
          }
        }
      }
    },


    /**
     * TODOC
     *
     * @param arbol {var} TODOC
     * @return {var} TODOC
     */
    _getTreeConfig : function(arbol)
    {
      var ret = {};
      ret["node"] = null;
      var hijos = arbol["childs"];
      var len = hijos.length;

      if (arbol["node"])
      {
        ret["node"] = {};
        var menuCheckBox = arbol["node"]["checkbox"];
        ret["node"]["id"] = arbol["node"]["id"];
        ret["node"]["type"] = arbol["node"]["type"];
        ret["node"]["selected"] = menuCheckBox.getChecked();
      }

      ret["childs"] = new Array();

      for (var i=0; i<len; i++)
      {
        var c = this._getTreeConfig(hijos[i]);
        ret["childs"].push(c);
      }

      return ret;
    }
  }
});
