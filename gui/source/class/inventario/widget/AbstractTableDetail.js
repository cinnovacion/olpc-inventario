
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
// AbstractTableDetail.js
// fecha: 2006-12-06
// autor: Kaoru Uchiyamada - kaoruj@fuzzylogic.com.py
// este es la clase que funciona con WindowDetail,
/*
@params oMethods es un hash que debe tener el list_url y una funcion que toma como parametro
un array (que seria la fila que fue seleccionada). tb data que es lo que se va mandar
*/

qx.Class.define("inventario.widget.AbstractTableDetail",
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
    this.setHandle(oMethods.handle);
    this.setData(oMethods.data);

    if (oMethods.boton)
    {
      this.setBoton(oMethods.boton);
      this.setBotonHandle(oMethods.botonHandle);
    }

    if (oMethods.printUrl && oMethods.printUrl != "") {
      this.setPrintUrl(oMethods.printUrl);
    }

    if (oMethods.printButton && oMethods.printButton != "") {
      this.setPrintButton(oMethods.printButton);
    }
  },




  /*
    *****************************************************************************
       PROPERTIES
    *****************************************************************************
    */

  properties :
  {
    handle :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    boton :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    botonHandle :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    printButton :
    {
      check : "String",
      init  : ""
    },

    printUrl :
    {
      check : "String",
      init  : ""
    },

    // data es un hash para mandar como parametro al servidor.. (comentario de Uchi)
    //
    //
    //  Pero ahora quedo en desuso.. Hay que encontrar un mecanismo p/ que PageNavigatorAbs pueda pasar parametros..
    //  Lo que vos hacias era redefinir show() pero eso trae otros problemas entonces tuve que borrar eso
    data : { check : "Object" }
  },




  /*
    *****************************************************************************
       MEMBERS
    *****************************************************************************
    */

  members :
  {
    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    addButtons : function()
    {
      // si es null significa que este el detalle final, o sea no hay mas otra ventana q crear
      if (this.getHandle() == null) return new qx.ui.layout.HorizontalBoxLayout;

      var hbox = new qx.ui.layout.HorizontalBoxLayout;
      hbox.setDimension("auto", "auto");

      var boton = new qx.ui.form.Button("Ver Detalles", "icon/16/mimetypes/x-office-spreadsheet.png");

      boton.addListener("execute", function(e)
      {
        var rows = inventario.widget.Table.getSelected(this.table, null);
        this.getHandle().call(this, rows[0]);
      },
      this);

      // ve si la clase que usa este no quiere ingresar otro boton para otra funcion que no es ver los detalles
      if (this.getBoton())
      {
        hbox.add(this.getBoton());

        this.getBoton().addListener("execute", function(e)
        {
          var rows = inventario.widget.Table.getSelected(this.table, null);
          this.getBotonHandle().call(this, rows[0]);
        },
        this);
      }

      hbox.add(boton);

      /* Boton de impresion */

      var pu = this.getPrintUrl();

      if (pu && pu != "")
      {
        var pb = this.getPrintButton();
        var pstr = pb && pb != "" ? pb : "Imprimir";
        var printButton = new qx.ui.form.Button(pstr, "icon/16/devices/printer.png");

        printButton.addListener("execute", function(e)
        {
          var row = inventario.widget.Table.getSelected2(this.table, [ 0 ], false);

          if (row && row.length > 0) {
            this._print(row[0]);
          } else {
            inventario.window.Mensaje.mensaje("Debe seleccionar una fila");
          }
        },
        this);

        hbox.add(printButton);
      }

      return hbox;
    },


    /**
     * _print():
     *
     * @param id {var} id p/ el metodo de impresion
     * @return {void} void
     */
    _print : function(id)
    {
      if (confirm("Imprimir?"))
      {
        var pu = this.getPrintUrl();
        var iframe = new qx.ui.embed.Iframe(pu + id);
        qx.ui.core.ClientDocument.getInstance().add(iframe);
      }
    }
  }
});