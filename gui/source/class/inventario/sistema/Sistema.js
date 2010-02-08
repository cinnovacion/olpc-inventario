
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
// Sistema.js
// fecha: 2006-11-20
// autor: Raul Gutierrez S. - rgs@fuzzylogic.com.py
// desde aca se manejan las tablas parametricas y las configuraciones del sistema
//
//
qx.Class.define("inventario.sistema.Sistema",
{
  extend : qx.core.Object,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function(page)
  {
    // llamar al constructor del padre
    if (page) {
      this.setPage(page);  // guardar la pagina
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
    page       : { check : "Object" },
    menuBar    : { check : "Object" },
    accessHash : { check : "Object" }
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
                   *  Accesos
                   */

      if (accessHash.menues || accessHash.submenues || accessHash.buttons || accessHash.roles)
      {
        var h =
        {
          label : "Accesos",
          icon  : "aisa/image/32/password.png"
        };

        var accesos = new inventario.sistema.Accesos(
        {
          menues    : accessHash.menues,
          submenues : accessHash.submenues,
          buttons   : accessHash.buttons,
          roles     : accessHash.roles
        });

        h["handler"] = accesos.show;
        h["obj"] = accesos;
        h["checked"] = false;

        menuItems.push(h);
      }

      /*
                   *  ABM de Usuarios (empleados)
                   */

      if (accessHash.users)
      {
        var h =
        {
          label : "Usuarios",
          icon  : "aisa/image/32/users4_2.png"
        };

        var usuarios = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("personas"));
        usuarios.setVista("usuarios");

        var configs = new Array();
        var res = inventario.widget.Url.getUrl("personas");

        configs.push(
        {
          InitialDataUrl : res["addUrl"],
          SaveUrl        : res["saveUrl"],
          titulo         : "Persona",
          select         : "personas",
          showSelect     : true
        });

        var res = inventario.widget.Url.getUrl("usuarios");

        configs.push(
        {
          InitialDataUrl : res["addUrl"],
          SaveUrl        : res["saveUrl"],
          titulo         : "Usuario",
          select         : "usuarios",
          showSelect     : true
        });

        usuarios.setMultiAbmFormConfigs(configs);

        h["handler"] = usuarios.show;
        h["obj"] = usuarios;
        h["checked"] = false;

        menuItems.push(h);
      }

      /*
                   *  ABM de Empleados (empleados)
                     "empleados" por el momento elimine el filtro
                   */

      if (accessHash.employees)
      {
        var h =
        {
          label : "Empleados",
          icon  : "aisa/image/32/users3_2.png"
        };

        var empleados = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("personas"));
        empleados.setVista("");

        var configs = new Array();
        var res = inventario.widget.Url.getUrl("personas");

        configs.push(
        {
          InitialDataUrl : res["addUrl"],
          SaveUrl        : res["saveUrl"],
          titulo         : "Persona",
          select         : "personas",
          showSelect     : true
        });

        var res = inventario.widget.Url.getUrl("empleados");

        configs.push(
        {
          InitialDataUrl : res["addUrl"],
          SaveUrl        : res["saveUrl"],
          titulo         : "Empleado",
          select         : "empleados",
          showSelect     : true
        });

        empleados.setMultiAbmFormConfigs(configs);

        empleados.setPaginated(true);

        h["handler"] = empleados.show;
        h["obj"] = empleados;
        h["checked"] = false;

        menuItems.push(h);
      }

      /*
                   *  Configuracion
                   */

      if (accessHash.configuracion)
      {
        var h =
        {
          label : "Configuracion",
          icon  : "aisa/image/32/configuracion.png"
        };

        var tw = new inventario.widget.Tabwindow();
        var titems = new Array();

        /* ABM de Tipos de Certificados */

        var h1 =
        {
          label : "Comprobantes",
          icon  : "icon/16/devices/video-display.png"
        };

        var comprobantes = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("comprobantes"));

        h1["handler"] = comprobantes.show;
        h1["obj"] = comprobantes;
        h1["checked"] = false;
        titems.push(h1);

        /* ABM de Tipos de Documentos */

        var h1 =
        {
          label : "Documentos",
          icon  : "icon/16/devices/video-display.png"
        };

        var documentos = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("documentos"));

        h1["handler"] = documentos.show;
        h1["obj"] = documentos;
        h1["checked"] = false;
        titems.push(h1);

        /* ABM de Prioridades */

        var h1 =
        {
          label : "Prioridades",
          icon  : "icon/16/devices/video-display.png"
        };

        var prioridades = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("prioridades"));

        h1["handler"] = prioridades.show;
        h1["obj"] = prioridades;
        h1["checked"] = false;
        titems.push(h1);

        /* ABM de Estados */

        var h1 =
        {
          label : "Estados",
          icon  : "icon/16/devices/video-display.png"
        };

        var estados = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("estados"));

        h1["handler"] = estados.show;
        h1["obj"] = estados;
        h1["checked"] = false;
        titems.push(h1);

        /* ABM de Transacciones */

        var h1 =
        {
          label : "Transacciones",
          icon  : "icon/16/devices/video-display.png"
        };

        var transacciones = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("transacciones"));

        h1["handler"] = transacciones.show;
        h1["obj"] = transacciones;
        h1["checked"] = false;
        titems.push(h1);

        /* ABM de Subtransacciones */

        var h1 =
        {
          label : "SubTransacciones",
          icon  : "icon/16/devices/video-display.png"
        };

        var subtransacciones = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("sub_transacciones"));

        h1["handler"] = subtransacciones.show;
        h1["obj"] = subtransacciones;
        h1["checked"] = false;
        titems.push(h1);

        /* Talonarios */

        var h1 =
        {
          label : "Talonarios",
          icon  : "icon/16/devices/video-display.png"
        };

        var talonarios = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("talonarios"));
        talonarios.setPaginated(true);
        h1["handler"] = talonarios.show;
        h1["obj"] = talonarios;
        h1["checked"] = false;
        titems.push(h1);

        /* Parametros Varios */

        var h1 =
        {
          label : "Parametros",
          icon  : "icon/16/devices/video-display.png"
        };

        var aisa_params = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("parametros"));
        aisa_params.setPaginated(true);
        h1["handler"] = aisa_params.show;
        h1["obj"] = aisa_params;
        h1["checked"] = false;
        titems.push(h1);

        tw.setTabItems(titems);

        h["handler"] = tw.show;
        h["obj"] = tw;
        h["checked"] = false;

        menuItems.push(h);
      }

      /*
                   *  Regional
                   */

      if (accessHash.regional)
      {
        var h =
        {
          label : "Regional",
          icon  : "aisa/image/32/world.png"
        };

        var tw = new inventario.widget.Tabwindow();
        var titems = new Array();

        /* ABM de Paises */

        var h1 =
        {
          label : "Paises",
          icon  : "icon/16/devices/video-display.png"
        };

        var paises = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("paises"));

        h1["handler"] = paises.show;
        h1["obj"] = paises;
        h1["checked"] = false;
        titems.push(h1);

        /* ABM de Departamentos */

        var h1 =
        {
          label : "Departamentos",
          icon  : "icon/16/devices/video-display.png"
        };

        var provincias = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("departamentos"));

        h1["handler"] = provincias.show;
        h1["obj"] = provincias;
        h1["checked"] = false;
        titems.push(h1);

        /* ABM de Ciudades */

        var h1 =
        {
          label : "Ciudades",
          icon  : "icon/16/devices/video-display.png"
        };

        var ciudades = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("ciudades"));

        h1["handler"] = ciudades.show;
        h1["obj"] = ciudades;
        h1["checked"] = false;
        titems.push(h1);

        tw.setTabItems(titems);

        h["handler"] = tw.show;
        h["obj"] = tw;
        h["checked"] = false;

        menuItems.push(h);
      }

      /*
                   *  Locales
                   */

      if (accessHash.locales)
      {
        var h =
        {
          label : "Locales",
          icon  : "aisa/image/32/houses.png"
        };

        var tw = new inventario.widget.Tabwindow();
        var titems = new Array();

        /* ABM de Oficinas */

        var h1 =
        {
          label : "Oficinas",
          icon  : "icon/16/devices/video-display.png"
        };

        var oficinas = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("oficinas"));

        h1["handler"] = oficinas.show;
        h1["obj"] = oficinas;
        h1["checked"] = false;
        titems.push(h1);

        /* ABM de Depositos */

        var h1 =
        {
          label : "Depositos",
          icon  : "icon/16/devices/video-display.png"
        };

        var depositos = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("depositos"));

        h1["handler"] = depositos.show;
        h1["obj"] = depositos;
        h1["checked"] = false;
        titems.push(h1);

        tw.setTabItems(titems);

        h["handler"] = tw.show;
        h["obj"] = tw;
        h["checked"] = false;

        menuItems.push(h);
      }

      /*
                   *  Editor de Planillas
                   */

      if (accessHash.grid_editor)
      {
        var h =
        {
          label : "Editor de Planillas",
          icon  : "aisa/image/32/ordenes.png"
        };

        var gridEditor = new inventario.window.GridEditor(null,
        {
          saveGridUrl : "/grid_editor/save",
          getGridUrl  : "/grid_editor/get",
          listGridUrl : "/grid_editor/list"
        });

        h["handler"] = gridEditor.show;
        h["obj"] = gridEditor;
        h["checked"] = false;

        menuItems.push(h);
      }

      /*
                   *  Auditoria
                   */

      if (accessHash.auditoria)
      {
        var h =
        {
          label : "Auditoria",
          icon  : "aisa/image/32/holmes2.png"
        };

        var auditoria = new inventario.window.Abm2(null, inventario.widget.Url.getUrl("auditoria"));

        auditoria.set(
        {
          paginated         : true,
          showAddButton     : false,
          showDeleteButton  : false,
          showModifyButton  : false,
          showDetailsButton : false,
          withArrayButton   : false,
          arrayButtonLen    : 0
        });

        h["handler"] = auditoria.show;
        h["obj"] = auditoria;
        h["checked"] = false;

        menuItems.push(h);
      }

      /*
                   *  Ayuda
                   */

      if (accessHash.helps)
      {
        var h =
        {
          label : "Ayuda",
          icon  : "aisa/image/32/help.png"
        };

        var helpAbm = new inventario.window.Abm2(null,
        {
          listUrl        : "/administrador/ayuda/search",
          addUrl         : "/administrador/ayuda/agregar",
          saveUrl        : "/administrador/ayuda/do_agregar",
          deleteUrl      : "/administrador/ayuda/eliminar",
          searchUrl      : "/administrador/ayuda/search",
          initialDataUrl : "/administrador/ayuda/search_options"
        });

        h["handler"] = helpAbm.show;
        h["obj"] = helpAbm;
        h["checked"] = false;

        menuItems.push(h);
      }

      var b = inventario.widget.Layout.createMenuBar(menuItems, "left");
      this.setMenuBar(b);
    }
  }
});