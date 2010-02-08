
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
// Datos.js
// fecha: 2008-01-02
// autor: rgs
//
// Varias funciones de conveniencia
//
qx.Class.define("inventario.util.Datos",
{
  extend : qx.core.Object,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function() {
    qx.core.Object.call(this);
  },




  /*
      *****************************************************************************
         STATICS
      *****************************************************************************
      */

  statics :
  {
    /**
     * Devuelve un vector con los datos de la columna
     *
     * @param datos {Array} matriz
     * @param col {Number} el nro. de columna cuyos datos se quiere recolectar
     * @return {var} TODOC
     */
    getColumna : function(datos, col)
    {
      var ret = [];
      var len = datos.length;

      /* por si col es null */

      if (!col) {
        col = 0;
      }

      for (var i=0; i<len; i++) {
        ret.push(datos[i][col]);
      }

      return ret;
    },


    /**
     * Devuelve un vector de configuraciones para un MultiAbm
     *
     * @return {var} TODOC
     */
    getConfigsProveedores : function()
    {
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

      var res = inventario.widget.Url.getUrl("proveedores");

      configs.push(
      {
        InitialDataUrl : res["addUrl"],
        SaveUrl        : res["saveUrl"],
        titulo         : "Proveedor",
        select         : "proveedores",
        showSelect     : true
      });

      return configs;
    }
  }
});