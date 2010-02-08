
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
qx.Class.define("inventario.widget.Validation",
{
  extend : qx.core.Object,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function() {},




  /*
      *****************************************************************************
         STATICS
      *****************************************************************************
      */

  statics :
  {
    /**
     * Validar campos
     *
     * @param value {var} TODOC
     * @param exceptionMsg {var} mensaje si levantamos la excepcion
     * @param inputType {var} tipo de input
     * @param re {var} expresion regular p/ validar campos de texto o comparacion en caso de numeric
     * @return {void} void
     * @throws TODOC
     */
    validate : function(value, exceptionMsg, inputType, re)
    {
      switch(inputType)
      {
        case "combobox":
          if (parseInt(value) <= 0) {
            throw exceptionMsg;
          }

          break;

        case "text":
          var r = new RegExp(re);
          var text = value ? value : "";

          if (!r.exec(text)) {
            throw exceptionMsg;
          }

          break;

        case "numeric":
          var ret = eval(value + re);

          if (!ret) {
            throw exceptionMsg;
          }

          break;

        case "fecha":

          /* primero verificar que haya string */

          inventario.widget.Validation.validate(value, exceptionMsg, "text", re);

          /* verificar formato */

          inventario.util.Fecha.validarFecha(value, exceptionMsg);

          break;

        default:
          inventario.window.Mensaje.mensaje("validate(): Tipo de input desconocido");
      }
    }
  }
});