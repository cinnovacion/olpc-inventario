
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
// WizardFinalPanel.js
// fecha: 2007-00-10
// autor: Raul Gutierrez S.
//
// Objetivo:
// - Desplegar todos los datos obtenidos
// - Guardar en el servidor y cerrar
//
//
qx.Class.define("inventario.window.WizardFinalPanel",
{
  extend : inventario.window.AbstractWindow,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function()
  {
    inventario.window.AbstractWindow.call(this);

    /*
         * Construir barra
         */

    var h =
    {
      type            : "button",
      icon            : "floppy_black",
      tooltip         : "Ctrl+G",
      accel_keyboard  : "Control+G",
      text            : "Guardar",
      callBackFunc    : this._guardar,
      callBackContext : this
    };

    this.getToolBarButtons().push(h);
  },




  /*
    *****************************************************************************
       PROPERTIES
    *****************************************************************************
    */

  properties : { datos : { check : "Object" } },




  /*
    *****************************************************************************
       MEMBERS
    *****************************************************************************
    */

  members :
  {
    /**
     * show():
     *
     * @return {void} void
     */
    show : function()
    {
      var vbox = new qx.ui.layout.VerticalBoxLayout();
      vbox.setDimension("100%", "100%");

      var vboxDatos = new qx.ui.layout.VerticalBoxLayout();
      vboxDatos.setDimension("100%", "90%");
      var len = this.getDatos().length;

      for (var i=0; i<len; i++)
      {
        var texto = qx.util.Json.stringify(this.getDatos()[i]);
        var l = new qx.ui.basic.Label(texto);
        vboxDatos.add(l);
      }

      vbox.add(vboxDatos);
      vbox.add(this._buildCommandToolBar());

      this._doShow2(vbox);
    },


    /**
     * _guardar():
     *  enviar datos al servidor
     *
     * @return {void} void
     */
    _guardar : function()
    {
      var opts = {};
      opts["url"] = this.getWizardObj().getSaveUrl();
      opts["data"] = { payload : qx.util.Json.stringify(this.getDatos()) };
      opts["parametros"] = null;
      opts["handle"] = this._guardarResp;
      inventario.transport.Transport.callRemote(opts, this);
    },


    /**
     * _guardarResp():
     *  recibir respuesta
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} void
     */
    _guardarResp : function(remoteData, params)
    {
      inventario.window.Mensaje.mensaje(remoteData["msg"]);

      if (remoteData["result"] == "ok") {}
    }
  }
});

/* Deberiamos cerrar nosotros o devolver el control a Wizard p/ que el se encargue? */