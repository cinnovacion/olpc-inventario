
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
// Libreria:  PageNavigatorAbstract.js
// fecha: 2006-10-27
// autor: Raul Gutierrez S. - rgs@fuzzylogic.com.py
// objeto generico para actualizacion de entidades
qx.Class.define("inventario.widget.PageNavigatorAbstract",
{
  extend : qx.core.Object,

  construct : function(page, list_url)
  {
    // llamar al constructor del padre
    if (page)
    {
      this.setPage(page);

      try
      {
        page.setDimension("100%", "100%");
        page.setHorizontalChildrenAlign("center");
        page.setVerticalChildrenAlign("center");
      }
      catch(e) {}
    }

    this.list_url = list_url;
    this.paginated = false;
  },

  properties :
  {
    paginated :
    {
      check : "Boolean",
      init  : false
    },

    page : { check : "Object" },
    groupBox : { check : "Object" },

    listTitle :
    {
      check : "String",
      init  : ""
    },

    verticalBox : { check : "Object" },
    tabla : { check : "Object" }
  },

  members :
  {
    /* La idea del groupBox es darle un titulo a la accion..
         *
         * El verticalBox es el agrupador de todos los elementos
         */

    show : function()
    {
      this.getPage().removeAll();  // limpiar ventana

      this.debug = false;  // activar esto para agregar nuevos metodos

      // crear la tabla
      this.table = false;

      this._pages = 1;  // pagina actual
      this._numPages = 0;  // cantidad de paginas en el listado

      var msg = this.getListTitle();
      var gb = new qx.ui.groupbox.GroupBox(msg);
      this.setGroupBox(gb);
      gb.setDimension("100%", "100%");
      this.getPage().add(gb);

      var vbox = new qx.ui.layout.VerticalBoxLayout;
      vbox.setDimension("100%", "100%");
      vbox.setHorizontalChildrenAlign("center");
      this.setVerticalBox(vbox);
      gb.add(vbox);

      // traer contenido
      var url = this.list_url;
      var data = { page : this._pages };

      inventario.transport.Transport.callRemote(
      {
        url        : url,
        parametros : null,
        handle     : this._getListResp,
        data       : data
      },
      this);
    },

    /**
     * TODOC
     *
     * @abstract 
     * @return {void} 
     * @throws the abstract function warning.
     * @abstract
     */
    addButtons : function() {
      throw new Error("addButtons is abstract");
    },


    /**
     * getListResp() :  cargar datos en la grilla
     *
     * @param datos {var} TODOC
     * @param handleParams {var} null (deberiamos recibir algunos inputs p/ cerar..
     * @return {void} void
     */
    _getListResp : function(datos, handleParams)
    {
      try
      {
        if (!this.table)
        {
          this.listColumns = datos["cols_titles"];  // titulos para el listado
          var h = new Array();
          var len = this.listColumns.length;

          for (var i=0; i<len; i++)
          {
            var width = (datos["widths"] && parseInt(datos["widths"][i])) ? parseInt(datos["widths"][i]) : 100;

            h.push(
            {
              titulo   : datos["cols_titles"][i],
              editable : false,
              width    : width
            });
          }

          this.table = inventario.widget.Table.createTable(h, "100%", "80%");
          this.table.getSelectionModel().setSelectionMode(qx.ui.table.selection.Model.MULTIPLE_INTERVAL_SELECTION);
          this.getVerticalBox().add(this.table);

          if (this.getPaginated())
          {
            this._numPages = datos["page_count"];

            // Botones de navegacion
            var hbox = new qx.ui.layout.HorizontalBoxLayout;
            hbox.setHorizontalChildrenAlign("left");

            var bPrev = new qx.ui.form.Button(qx.locale.Manager.tr("Previous"), "icon/16/actions/go-previous.png");

            bPrev.addListener("execute", function(e)
            {
              if (this._pages > 1)
              {
                this._pages--;
                var url = this.list_url;
                var data = { page : this._pages };

                inventario.transport.Transport.callRemote(
                {
                  url        : url,
                  parametros : null,
                  handle     : this._getListResp,
                  data       : data
                },
                this);
              }
            },
            this);

            hbox.add(bPrev);

            var bNext = new qx.ui.form.Button(qx.locale.Manager.tr("Next"), "icon/16/actions/go-next.png");

            bNext.addListener("execute", function(e)
            {
              if (this._numPages > this._pages)
              {
                this._pages++;
                var url = this.list_url;
                var data = { page : this._pages };

                inventario.transport.Transport.callRemote(
                {
                  url        : url,
                  parametros : null,
                  handle     : this._getListResp,
                  data       : data
                },
                this);
              }
            },
            this);

            hbox.add(bNext);

            this.getVerticalBox().add(hbox);
          }

          // Botones de manipulacion de datos
          var ab = this.addButtons();
          this.getVerticalBox().add(ab);
        }

        if (datos["rows"].length > 0)
        {
          inventario.widget.Table.setRenderers(this.table, datos["rows"][0]);
          this.table.getTableModel().setData(datos["rows"]);
        }

        this.setTabla(this.table);

        /* test para que la tabla acepte varios click para seleccionar varias filas a la vez */

        // this.getTabla().getSelectionModel().setSelectionMode(qx.ui.table.selection.Model.MULTIPLE_INTERVAL_SELECTION);
        // inventario.window.Mensaje.mensaje(this.getTabla().getSelectionModel().getSelectionMode());
        // var manag = new qx.ui.table.selection.Manager();
        // manag.setSelectionModel(this.getTabla().getSelectionModel());
        /* setTimeout(qx.ui.core.Widget.flushGlobalQueues, 1); */

        qx.ui.core.Widget.flushGlobalQueues();
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje(e);
      }
    },

    /*
         * TODO:  Esto no corresponde aca.. hay que llevar a a widget/Table.js
         */

    _getSelected : function(allRows)
    {
      var ret = new Array();
      var sm = this.table.getSelectionModel();
      var tm = this.table.getTableModel();
      var len = tm.getRowCount();

      for (var i=0; i<len; i++)
      {
        if (sm.isSelectedIndex(i))
        {

          /* debugging */

          if (this.debug) inventario.window.Mensaje.mensaje(qx.locale.Manager.tr("Row ") + i + qx.locale.Manager.tr(" is selected"));

          /*
                     * Warning: esto es una limitacion.. identificamos las filas por el valor de la primera columna, deberiamos
                     *          usar informacion privada a la fila
                     */

          ret.push(tm.getValue(0, i));
          if (!allRows) break;
        }
      }

      return ret;
    }
  }
});
