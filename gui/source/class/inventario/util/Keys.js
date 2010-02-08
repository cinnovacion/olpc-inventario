
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
// Keys.js
// fecha: 2007-08-29
// autor: rgs
//
// Manejo de aceleradores,etc.
//
qx.Class.define("inventario.util.Keys",
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
     * @param accel_key {var} TODOC
     * @param callback {var} TODOC
     * @param callback_ctxt {var} TODOC
     * @param widgetAsociarKeys {var} TODOC
     * @return {void} 
     */
    addAccelerator : function(accel_key, callback, callback_ctxt, widgetAsociarKeys)
    {
      /* Preparamos el contexto bajo el cual se va a llamar al callback..
                   *  entonces no tenemos problemas de scope..
                   */

      var obj = new qx.core.Object();
      obj.setUserData("callback", callback);
      obj.setUserData("callback_ctxt", callback_ctxt);
      obj.setUserData("accel_keyboard", accel_key);

      widgetAsociarKeys.addListener("keyup", function(e)
      {
        /* WARNING
                   *  el procesamiento que hacemos aca es bastante limitado.. puede morder :S
                   */

        var str = this.getUserData("accel_keyboard");
        var m = str.split(/\+/)[1];

        if (e.isCtrlPressed() && e.getKeyIdentifier() == m)
        {
          var cb_func = this.getUserData("callback");
          var cb_obj = this.getUserData("callback_ctxt");
          cb_func.call(cb_obj);
        }
      },
      obj);
    },

    /* Generar un acelerador para las barras laterales
             * -
             * @param accel_key {String} acelerador
             * @param msg {String} msg de activacion del boton
             * @param widget {Object} widget que recibe eventos del teclado
             * @return {void}
             *
             * FIXME: callback podria ser un metodo estatico (para ahorrar memoria)
             */

    /**
     * TODOC
     *
     * @param accel_key {var} TODOC
     * @param msg {var} TODOC
     * @param widget {var} TODOC
     * @return {void} 
     */
    addAcceleratorSideBar : function(accel_key, msg, widget)
    {
      var callback = function(e)
      {
        var mtxt = this.getUserData("mensaje");
        var m = new qx.event.message.Message(mtxt, true);
        qx.event.message.Bus.dispatch(m);
      };

      var callback_ctxt = new qx.core.Object();
      callback_ctxt.setUserData("mensaje", msg);
      inventario.util.Keys.addAccelerator(accel_key, callback, callback_ctxt, widget);
    }
  }
});