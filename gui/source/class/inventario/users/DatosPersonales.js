
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
/**
 * DatosPersonales.js
 * Kaoru Uchiyamada
 * last change 2007 - 05 - 17
 */
qx.Class.define("inventario.users.DatosPersonales",
{
  extend : qx.core.Object,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function(pagina)
  {
    // llamar al constructor del padre
    if (pagina) {
      this.setPage(pagina);  /* guardar la pagina */
    }

    this.prepared = false;
  },




  /*
      *****************************************************************************
         PROPERTIES
      *****************************************************************************
      */

  properties :
  {
    page : { check : "Object" },
    menuBar : { check : "Object" },
    accessHash : { check : "Object" },

    userName :
    {
      check : "String",
      init  : ""
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
     * activar(): activar barra
     *
     * @return {void} void
     *     
     *       TODO: activar() y el constructor se repiten en Todos los archivos principales de cada modulo (hay que factorizar esto)
     */
    activar : function()
    {

      /* borrar lo que estaba antes */

      this.getPage().removeAll();

      if (!this.prepared)
      {
        this._loadBar();
        this.prepared = true;
        var b = this.getMenuBar();
      }
      else
      {
        var b = this.getMenuBar();
        inventario.widget.Layout.uncheckedMenuBarItems(b);
      }

      /* mostrar lo que tenemos */

      this.getPage().add(b);
    },


    /**
     * _loadBar(): recibe hash de acceso
     *
     * @return {void} void
     */
    _loadBar : function()
    {
      var accessHash = this.getAccessHash();
      var menuItems = new Array();

      /*
                   *  Ver Perfil
                   */

      var h =
      {
        label : "Mi Perfil",
        icon  : "icon/32/perfil.png"
      };

      if (accessHash.ver_perfiles)
      {
        var perfiles = new inventario.users.VerPerfil(null);
        h["handler"] = perfiles.show;
        h["obj"] = perfiles;
        h["checked"] = false;
      }

      menuItems.push(h);

      var h =
      {
        label : "Mis Acciones",
        icon  : "icon/32/caja_llena.png"
      };

      if (accessHash.acciones_usuario)
      {
        var acciones = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("auditoria"));

        acciones.set(
        {
          paginated         : true,
          showAddButton     : false,
          showDeleteButton  : false,
          showModifyButton  : false,
          showDetailsButton : false,
          withArrayButton   : false,
          arrayButtonLen    : 0
        });

        acciones.setVista(this.getUserName());
        h["handler"] = acciones.show;
        h["obj"] = acciones;
        h["checked"] = false;
      }

      menuItems.push(h);

      var h =
      {
        label : "Cambiar Password",
        icon  : "icon/32/password2.png"
      };

      if (accessHash.cambiar_password)
      {
        var perfiles = new inventario.users.ChangePassword(null);
        h["handler"] = perfiles.show;
        h["obj"] = perfiles;
        h["checked"] = false;
      }

      menuItems.push(h);

      var b = inventario.widget.Layout.createMenuBar(menuItems, "left");
      this.setMenuBar(b);
    }
  }
});