
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
// PrintManager.js
// fecha: 2007-03-16
// autor: rgs
//
// Singleton p/ reciclar objetos
/**
 * Constructor
 *
 * @param param string
 */
qx.Class.define("inventario.util.PrintManager",
{
  extend : qx.core.Object,

  construct : function()
  {
    // llamar al constructor del padre
    qx.core.Object.call(this);
  },

  statics :
  {
    /**
     * print()
     *
     * @param documento {String} El identificador para obtener el URL del documento que queremos imprimir
     * @param params {Hash} Parametros para enviar al controller de impresion
     * @return {iFrame} que tiene que ser agregado al page del que esta llamando a print()
     */
    printExcel : function(documento, params)
    {
      var h = {};
      h["url"] = inventario.util.PrintManager.getPrintUrl(documento);
      h["url"] += "_carga_datos";
      h["parametros"] = documento;
      h["handle"] = inventario.util.PrintManager.printExcelResp;
      h["data"] = params;

      inventario.transport.Transport.callRemote(h, null);
    },

    printExcelResp : function(remoteData, documento)
    {
      var url = inventario.util.PrintManager.getPrintUrl(documento);
      window.open(url, '__new');
    },

    /**
     * getPrintUrl()
     *
     * @param documento {String} El identificador para obtener el URL del documento que queremos imprimir
     * @return {String} el url
     * @throws TODOC
     */
    getPrintUrl : function(documento)
    {
      var print_controller = "/print/";
      var excel_controller = "/planillas/";
      var url = "";

      if (documento == "planilla")
        return "/planillas/planilla";
      else
        return "/print/" + documento;
    }
  }
});
