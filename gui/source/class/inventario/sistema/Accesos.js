
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
// Accesos.js
// fecha: 2006-12-02
// autor: Raul Gutierrez S. - rgs@fuzzylogic.com.py
//
// Accesos: ABM de roles,menues,etc.
qx.Class.define("inventario.sistema.Accesos",
{
  extend : qx.core.Object,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function(hAccess)
  {
    // llamar al constructor del padre
    try
    {
      this.setMenues(hAccess.menues);
      this.setSubmenues(hAccess.submenues);
      this.setButtons(hAccess.buttons);
      this.setRoles(hAccess.roles);
    }
    catch(e) {}
  },




  /*
      *****************************************************************************
         PROPERTIES
      *****************************************************************************
      */

  properties :
  {
    page : { check : "Object" },

    menues :
    {
      check : "Object",
      init  : false
    },

    submenues :
    {
      check : "Object",
      init  : false
    },

    buttons :
    {
      check : "Object",
      init  : false
    },

    roles :
    {
      check : "Object",
      init  : false
    },

    tabBar : { check : "Object" }
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
      var tabItems = new Array();
      this.getPage().removeAll();

      /*
                   *  ABM de Menues
                   */

      var h =
      {
        label : "Menues",
        icon  : "icon/16/devices/video-display.png"
      };

      if (this.getMenues())
      {
        var menues = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("menues"));

        menues.setPaginated(true);
        h["handler"] = menues.show;
        h["obj"] = menues;
        h["checked"] = false;
      }

      tabItems.push(h);

      /*
                   *  ABM de SubMenues
                   */

      var h =
      {
        label : "SubMenues",
        icon  : "icon/16/devices/video-display.png"
      };

      if (this.getSubmenues())
      {
        var submenues = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("sub_menues"));

        submenues.setPaginated(true);
        h["handler"] = submenues.show;
        h["obj"] = submenues;
        h["checked"] = false;
      }

      tabItems.push(h);

      /*
                   *  ABM de Botones
                   */

      var h =
      {
        label : "Acciones",
        icon  : "icon/16/devices/video-display.png"
      };

      if (this.getButtons())
      {
        var buttons = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("acciones"));

        buttons.setPaginated(true);
        h["handler"] = buttons.show;
        h["obj"] = buttons;
        h["checked"] = false;
      }

      tabItems.push(h);

      /*
                   *  ABM de Roles
                   */

      var h =
      {
        label : "Perfiles",
        icon  : "icon/16/devices/video-display.png"
      };

      if (this.getRoles())
      {
        var roles = new inventario.sistema.Roles(
        {
          list_url   : "/administrador/parametricas/roles/listar",
          save_url   : "/administrador/parametricas/roles/do_agregar",
          delete_url : "/administrador/parametricas/roles/eliminar"
        });

        h["handler"] = roles.show;
        h["obj"] = roles;
        h["checked"] = false;
      }

      tabItems.push(h);

      var tb = inventario.widget.Layout.createTabBar(tabItems);
      this.setTabBar(tb);
      this.getPage().add(tb);
    },


    /**
     * _deleteRoleResp():
     *
     * @return {void} void
     */
    ejemplo : function() {}
  }
});