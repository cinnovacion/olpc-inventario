
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
// HelpWindow.js
// fecha: 2007-01-10
// autor: Raul Gutierrez S. - rgs@fuzzylogic.com.py
//
// Popup con ayuda.
//
qx.Class.define("inventario.window.HelpWindow",
{
  extend : inventario.window.AbstractWindow,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function(options)
  {
    inventario.window.AbstractWindow.call(this, null);
    this.prepared = false;

    /* Cargar parametros sinhe quae non */

    try
    {
      this.setTextUrl(options.textUrl);
      this.setHelpName(options.helpName);
    }
    catch(e)
    {
      inventario.window.Mensaje.mensaje("Falta un parametro en el hash de urls! " + e);
    }

    /*
         * Crear Popup
         */

    var winObj = new inventario.widget.Window();
    winObj.getWindow().setModal(true);
    this.setWindow(winObj);
  },




  /*
    *****************************************************************************
       PROPERTIES
    *****************************************************************************
    */

  properties :
  {

    /* RPC */

    textUrl :
    {
      check : "String",
      init  : ""
    },

    helpName :
    {
      check : "String",
      init  : ""
    },

    /*
         *  Widgets & Inputs
         */

    window : { check : "Object" },
    textLabel : { check : "Object" }
  },




  /*
    *****************************************************************************
       MEMBERS
    *****************************************************************************
    */

  members :
  {
    /**
     * _createInputs()
     *
     * @return {void} 
     */
    _createInputs : function() {},


    /**
     * _setHandlers(): metodo abstracto
     *
     * @return {void} 
     */
    _setHandlers : function() {},


    /**
     * _createLayout(): metodo abstracto
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var a = new qx.ui.basic.Atom();
      a.setDimension("auto", "auto");
      a.setBorder("black");
      a.setBackgroundColor("white");
      a.setPadding(4);
      this.setTextLabel(a);
      this.getWindow().getVbox().add(a);
    },


    /**
     * _loadInitialData(): metodo abstracto
     *
     * @return {void} 
     */
    _loadInitialData : function()
    {
      var url = this.getTextUrl();
      var dhash = {};
      dhash["help_name"] = this.getHelpName();

      inventario.transport.Transport.callRemote(
      {
        url        : url,
        parametros : null,
        handle     : this._loadInitialDataResp,
        data       : dhash
      },
      this);
    },


    /**
     * _loadInitialDataResp():
     *
     * @param remoteData {var} TODOC
     * @param params {var} TODOC
     * @return {void} 
     */
    _loadInitialDataResp : function(remoteData, params)
    {

      /* agregar el texto */

      var text = remoteData["text"];
      this.getTextLabel().setLabel(text);
      this.prepared = true;
      this._doShow();
    },


    /**
     * show(): vemos si ya esta todo preparado o aun no se armo la ventana. De esta forma se demora el RPC hasta el primer evento
     *         que nos llama y tambien queda todo (objetos y datos venidos del servidor) cacheados p/ la proximas veces.
     *
     * @return {void} void
     */
    show : function()
    {
      if (this.prepared)
      {

        /* Habria que cerar widgets antes de empezar */

        this._doShow();
      }
      else
      {

        /* traer datos y preparar widgets */

        this._createInputs();
        this._setHandlers();
        this._createLayout();
        this._loadInitialData();
      }
    },


    /**
     * _doShow()
     *
     * @return {void} void
     */
    _doShow : function()
    {

      /* ajustar el tamanho del popup al del atom (el cual esperamos que ya tenga width y height p/ este entonces) */

      /*    var a = this.getTextLabel();
            var w = a.getWidth();
            var h = a.getHeight();
            if (w && h) {
              w = parseInt(w);
              h = parseInt(h);
      
              if (h && w) {
             var extra = 20;
             this.getWindow().setDimension(w+extra,h+extra);
              }
              } */

      this.getWindow().show();
    }
  }
});