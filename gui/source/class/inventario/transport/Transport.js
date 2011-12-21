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


qx.Class.define("inventario.transport.Transport",
{
  extend : qx.core.Object,

  construct : function(page) {},

  statics :
  {
    TRANSPORT_TIMEOUT : 20000,

    /**
     * TODOC
     *
     * @param params {Hash} :url,
     *                        :file_upload => si estamos subiendo un archivo,
     *                        :data       => hash de parametros para el metodo del controller,
     *                        :handle     => callback,
     *                        :parametros => parametros para el callback
     * @param self {Object} referencia al objeto llamante
     * @return {void} void
     */
    callRemote : function(params, self)
    {
      if (params.file_upload) {
        inventario.transport.Transport.doCallRemoteIframe(params, self);
      } else {
        inventario.transport.Transport.doCallRemote(params, self);
      }
    },

    /**
     * TODOC
     *
     * @param params {Hash} :url,
     *                        :file_upload_form => referencia a instancia de uploadwidget.UploadForm
     *                        :data       => hash de parametros para el metodo del controller,
     *                        :handle     => callback,
     *                        :parametros => parametros para el callback
     * @param self {var} TODOC
     * @return {void} void
     */
    doCallRemoteIframe : function(params, self) {
      var form = params.file_upload_form;

      if (params.data) {
        for (var k in params.data) {
          form.setParameter(k, params.data[k]);
        }
      }

      form.addListenerOnce('completed', function(e)
      {
        var response = this.getIframeHtmlContent();
        inventario.transport.Transport._callRemoteResp(response, params.handle, params.parametros, self);
      });

      try {
        form.send();
      } catch(e) {
        alert("Transport => " + e.toString());
      }
    },

    /**
     * TODOC
     *
     * @param params {Hash} :url,
     *                        :data       => hash de parametros para el metodo del controller,
     *                        :handle     => callback,
     *                        :parametros => parametros para el callback
     * @param self {Object} referencia al objeto llamante
     * @return {void} void
     */
    doCallRemote : function(params, self) {
      params.data = params.data == null ? {} : params.data;
      var http_method = (qx.lang.Object.isEmpty(params.data) ? "GET" : "POST");
      var req = new qx.io.remote.Request(params.url, http_method);

      req.setTimeout(inventario.transport.Transport.TRANSPORT_TIMEOUT);

      if (!params.async) req.setAsynchronous(true);
      else req.setAsynchronous(false);

      req.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

      if (params.data) {
        for (var k in params.data) {
          req.setFormField(k, params.data[k]);
        }
      }

      var statusWin = inventario.transport.Transport.getStatusWin();

      var _finish_cb = function(e) {
        statusWin.close();
      };

      req.addListener("sending", function(e) {
        statusWin.getUserData("message_text").setLabel(qx.locale.Manager.tr("Sending request..."));
      });

      req.addListener("receiving", function(e) {
        statusWin.getUserData("message_text").setLabel(qx.locale.Manager.tr("Receiving data..."));
      });

      req.addListener("aborted", function(e)
      {
        statusWin.getUserData("message_text").setLabel(qx.locale.Manager.tr("Aborted your order..."));

        setTimeout(_finish_cb, 2000);
      });

      req.addListener("timeout", function(e)
      {
        statusWin.getUserData("message_text").setLabel(qx.locale.Manager.tr("Timed out, try again..."));
        setTimeout(_finish_cb, 2000);
      });

      req.addListener("failed", function(e)
      {
        statusWin.getUserData("message_text").setLabel(qx.locale.Manager.tr("Failure on your order..."));
        setTimeout(_finish_cb, 2000);
      });

      req.addListener("completed", function(e)
      {
        statusWin.close();
        inventario.transport.Transport._callRemoteResp(e, params.handle, params.parametros, self);
      });

      try {
        statusWin.open();
        req.send();
      } catch(e) {
        alert("Transport => " + e.toString());
      }
    },

    _callRemoteResp : function(e, f_callback, f_params, self)
    {
        var c;

        if (typeof (e) == "object") {
          c = e.getContent();
        } else {
          c = e;
        }

        var datos = qx.util.Json.parse(c, true);

        if (datos["result"] == "ok") {
          f_callback.call(self, datos, f_params);
        } else {
          var tipoDeMsg = (datos["tipoDeMsg"] ? datos["tipoDeMsg"] : "critical");
          var debuggingMsg = (datos["codigo"] ? datos["codigo"] : null);

          inventario.window.Mensaje.mensaje(datos["msg"], null, null, datos["result"], datos["result"], tipoDeMsg, debuggingMsg);
        }
    },

    /**
     * buildParamStr
     *
     * @param params {Hash} Parametros para enviar al controller de impresion
     * @param codificar {var} TODOC
     * @return {String} de la forma "?key1=val1&key2=val2"
     */
    buildParamStr : function(params, codificar) {
      var ret = "?";

      for (var i in params) {
        var p = (codificar ? encodeURIComponent(params[i]) : params[i]);
        ret += i + "=" + p + "&";
      }

      return ret;
    },

    getStatusWin : function() {
      var messageText = new qx.ui.basic.Atom(qx.locale.Manager.tr("Processing your request..."));

      var statusWin = new inventario.widget.Window();
      statusWin.setShowMaximize(false);
      statusWin.setShowMinimize(false);
      statusWin.setShowClose(false);
      statusWin.setOpacity(0.7);
      statusWin.getVbox().add(messageText);
      statusWin.getVbox().add(inventario.transport.Transport.getProcessingImage());
      statusWin.setModal(true);
      statusWin.center();

      statusWin.setUserData("message_text", messageText);

      return statusWin;
    },

    processingImage : null,

    /**
     * getProcessingImage
     *
     * @return {qx.ui.basic.Image} TODOC
     */
    getProcessingImage : function() {
      if (!inventario.transport.Transport.processingImage) {
        inventario.transport.Transport.processingImage = new qx.ui.basic.Image("inventario/22/wait.gif");
      }

      return inventario.transport.Transport.processingImage;
    }
  }
});
