
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
// Fecha.js
// fecha: 2007-09-03
// autor: rgs
//
// Validaciones y funciones auxiliares para fechas
//
qx.Class.define("inventario.util.Fecha",
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
     * TODOC
     *
     * @param fecha_str {var} TODOC
     * @param nombre_campo {var} TODOC
     * @return {void} 
     * @throws TODOC
     */
    validarFecha : function(fecha_str, nombre_campo)
    {
      if (!fecha_str.match(/\d\d-\d\d-\d\d\d\d/)) {
        throw new Error("El campo " + nombre_campo + " no tiene el formato correcto. Debe ser dd-mm-aaaa");
      }
    },


    /**
     * TODOC
     *
     * @param fecha {var} TODOC
     * @param dias {var} TODOC
     * @return {var} TODOC
     */
    suma : function(fecha, dias)
    {
      var oneMinute = 60 * 1000;  // milliseconds in a minute
      var oneHour = oneMinute * 60;
      var oneDay = oneHour * 24;

      var v = fecha.split(/-/);
      fecha = v[2] + "/" + v[1] + "/" + v[0];
      var today = new Date(fecha);
      var dateInMS = today.getTime() + (oneDay * dias);
      var targetDate = new Date(dateInMS);

      var anho = (targetDate.getYear() - 100) + 2000;
      var m = targetDate.getMonth() + 1;
      var mes = inventario.util.Fecha.padStr(m.toString(), 2, "0");
      var dia = inventario.util.Fecha.padStr(targetDate.getDate(), 2, "0");
      return dia + "-" + mes + "-" + anho;
    },


    /**
     * TODOC
     *
     * @param str {String} TODOC
     * @param len {var} TODOC
     * @param padChar {var} TODOC
     * @return {var} TODOC
     */
    padStr : function(str, len, padChar)
    {
      if (padChar == null) {
        padChar = " ";
      }

      var ret = str.toString();

      if (ret.length < len)
      {
        var veces = len - ret.length;

        for (var i=0; i<veces; i++) {
          ret = padChar + ret;
        }
      }

      return ret;
    }
  }
});