
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
// AbstractWindow.js
// fecha: 2006-12-21
// autor: Raul Gutierrez S.
//
//
// Clase que implementa un patron de disenho para interfaces graficas teniendo en cuenta a los sgtes. actores
// - inputs
// - handlers de los inputs (interactuacion entre inputs + validacion con el evento "blur")
// - la disposicion (layout)
// - carga de datos iniciales
// - validacion final (mas generica que las primeras)
// - envio de datos al servidor

qx.Class.define("inventario.window.AbstractWindow",
{
  extend : qx.core.Object,

  construct : function(page)
  {
    if (page) {
      this.setPage(page);
    }

    var o = new Array();
    this.setToolBarButtons(o);

    var v = new Array();
    this.setAceleradores(v);
  },

  properties :
  {
    page :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    toolBarButtons :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    toolBar :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    exitCallback :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    exitCallbackContext :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    editingId :
    {
      check : "Number",
      init  : 0
    },

    editingRows :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    impresionFrame :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    commandsManager :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    commandsManager :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    usePopup :
    {
      check : "Boolean",
      init  : false
    },

    windowTitle :
    {
      check : "String",
      init  : "",
      apply : "_applyWindowTitle"
    },

    abstractPopupWindow :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    abstractWindowReadOnly :
    {
      check : "Boolean",
      init  : false
    },

    abstractPopupWindowHeight :
    {
      check : "Number",
      init  : 0
    },

    abstractPopupWindowWidth :
    {
      check : "Number",
      init  : 0
    },

    askConfirmationOnClose :
    {
      check : "Boolean",
      init  : true
    },

    aceleradores :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    onCloseCallBack :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    onCloseCallBackContext :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    savedChanges :
    {
      check : "Boolean",
      init  : false
    },

    closeAfterSave :
    {
      check : "Boolean",
      init  : false
    },

    textBackgroundColor :
    {
      check : "String",
      init  : "#EEEEEE"
    },

    overFlow :
    {
      check : "String",
      init  : "auto"
    },

    arrayBotones :
    {
      check : "Object",
      init  : null
    }
  },

  members :
  {
    /**
     * _createInputs(): metodo abstracto,hay que redefinir
     *
     * @abstract 
     * @return {void} 
     * @throws the abstract function warning.
     * @abstract
     */
    _createInputs : function() {
      throw new Error("createInputs is abstract");
    },


    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    getWindowIcon : function() {
      var icon = this.getAbstractPopupWindow().getWindow().getIcon();
      return icon;
    },


    /**
     * _setHandlers(): metodo abstracto
     * 
     * Aqui hay que establecer interacciones entre inputs,botones & validaciones
     *
     * @abstract 
     * @return {void} 
     * @throws the abstract function warning.
     * @abstract
     */
    _setHandlers : function() {
      throw new Error("setHandlers is abstract");
    },


    /**
     * _createLayout(): metodo abstracto
     * 
     * Posicionamiento de inputs
     *
     * @abstract 
     * @return {void} 
     * @throws the abstract function warning.
     * @abstract
     */
    _createLayout : function() {
      throw new Error("createLayout is abstract");
    },


    /**
     * _loadInitialData(): metodo abstracto
     *
     * @abstract 
     * @return {void} 
     * @throws the abstract function warning.
     * @abstract
     */
    _loadInitialData : function() {
      throw new Error("loadInitialData is abstract");
    },


    /**
     * _validateData(): metodo abstracto
     *
     * @abstract 
     * @return {void} 
     * @throws the abstract function warning.
     * @abstract
     */
    _validateData : function() {
      throw new Error("validateData is abstract");
    },


    /**
     * _saveData(): metodo abstracto
     *
     * @abstract 
     * @return {void} 
     * @throws the abstract function warning.
     * @abstract
     */
    _saveData : function() {
      throw new Error("saveData is abstract");
    },

    /**
     * TODOC
     *
     * @abstract 
     * @return {void} 
     * @throws the abstract function warning.
     * @abstract
     */
    _exitWindow : function() {
      throw new Error("_exitWindow() is abstract");
    },

    /**
     * TODOC
     *
     * @return {void} 
     */
    cerrar : function() {
      this.getAbstractPopupWindow().getWindow().close();
    },

    /**
     * TODOC
     *
     * @param arriba {var} TODOC
     * @param distancia {var} TODOC
     * @return {var} TODOC
     */
    _buildCommandToolBar : function(arriba, distancia)
    {
      var tb = new qx.ui.toolbar.ToolBar;
      var btns = this.getToolBarButtons();

      if (!distancia) distancia = 10;

      if (!arriba) {
	tb.setBottom(distancia);
      }
      
      // ceramos hash de botones
      this.setArrayBotones({});

      for (var i=0; i<btns.length; i++) {
        var btn = btns[i];
        var callback = btn.callBackFunc;
        var callback_ctxt = btn.callBackContext;

        switch(btn.type) {
          case "separator":
            var o = new qx.ui.toolbar.Separator;
            break;
          case "button":
            var o = this._doAddToolbarButton(btn, callback, callback_ctxt);
            break;
          case "toolBarButton":
            var o = btn.object;
            break;
        }

        tb.add(o);
      }

      this.setToolBar(tb);

      return tb;
    },

    /**
     * TODOC
     *
     * @return {void} 
     */
    doMaximize : function()
    {
      var window = this.getAbstractPopupWindow().getWindow();
      window.open();
    },


    /**
     * TODOC
     *
     * @param label {var} TODOC
     * @param key_accel {var} TODOC
     * @return {var} TODOC
     */
    _underlineLabel : function(label, key_accel)
    {
      var ret = "";
      var str;

      if (key_accel.match(/\+/))
      {
        var v = key_accel.split(/\+/);
        var i = v.length - 1;
        str = v[i];
      }
      else
      {

        /* esta rama no deberia usarse.. */

        str = key_accel;
      }

      str = str.toLowerCase();
      var subraye = false;

      for (var j=0; j<label.length; j++)
      {
        if (label[j].toLowerCase() == str && !subraye)
        {
          ret += "<u>" + label[j] + "</u>";
          subraye = true;
        }
        else
        {
          ret += label[j];
        }
      }

      return ret;
    },


    /**
     * TODOC
     *
     * @param vbox {var} TODOC
     * @return {void} 
     */
    _doShow2 : function(vbox)
    {
      var page;
      var widgetAsociarKeys;

      if (this.getUsePopup())
      {
        var w = this.getAbstractPopupWindow();

        if (!w)
        {
          var t = (this.getWindowTitle() ? this.getWindowTitle() : " ");
          w = new inventario.widget.Window({ title : t });
          this.setAbstractPopupWindow(w);

          /* Le indicamos a la ventana (widget.Window) que consulte con nosotros si hubo cambios para 
          	   * llamar al callback al cerrar la ventana
          	   * la consulta de si hubo cambios es via getSavedChanges
          	   */

          w.setRelatedObj(this);
          w.setOnCloseCallBack(this.getOnCloseCallBack());
          w.setOnCloseCallBackContext(this.getOnCloseCallBackContext());

          var height = this.getAbstractPopupWindowHeight();
          var width = this.getAbstractPopupWindowWidth();

          if (height > 0) {
            this.getAbstractPopupWindow().getWindow().setHeight(height);
          }

          if (width > 0) {
            this.getAbstractPopupWindow().getWindow().setWidth(width);
          }

          this.getAbstractPopupWindow().getWindow().setModal(false);

          /* Manejar Esc. como cierre de ventana */

          this.getAbstractPopupWindow().getWindow().addListener("keyup", this._escape_cb, this);

          // minimize to the application taskbar
          this.getAbstractPopupWindow().getWindow().addListener("minimize", this._minimize_cb, this);
        }

        page = this.getAbstractPopupWindow().getVbox();
        inventario.widget.Layout.removeChilds(page);
        page.add(vbox);
        this.getAbstractPopupWindow().show();
        widgetAsociarKeys = this.getAbstractPopupWindow().getWindow();
      }
      else
      {
        page = this.getPage();
        inventario.widget.Layout.removeChilds(page);
        page.add(vbox);
        widgetAsociarKeys = page;
      }

    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _minimize_cb : function()
    {
      var taskbar = inventario.widget.TaskBar.getInstance();
      taskbar.minimize(this);
    },

    /**
     * TODOC
     *
     * @param key_str {var} TODOC
     * @param func {Function} TODOC
     * @param obj {Object} TODOC
     * @return {void} 
     */
    _addAccelerator : function(key_str, func, obj)
    {
      var h = {};
      h["key"] = key_str;
      h["func"] = func;
      h["obj"] = obj;
      this.getAceleradores().push(h);
    },

    /**
     * TODOC
     *
     * @param accel_key {var} TODOC
     * @param callback {var} TODOC
     * @param callback_ctxt {var} TODOC
     * @param widgetAsociarKeys {var} TODOC
     * @return {void} 
     */
    _doAddAccelerator : function(accel_key, callback, callback_ctxt, widgetAsociarKeys) {
      inventario.util.Keys.addAccelerator(accel_key, callback, callback_ctxt, widgetAsociarKeys);
    },


    /**
     * TODOC
     *
     * @param btn {var} TODOC
     * @param callback {var} TODOC
     * @param callback_ctxt {var} TODOC
     * @return {Object} TODOC
     */
    _doAddToolbarButton : function(btn, callback, callback_ctxt)
    {
      var text = btn.text;

      var o = new qx.ui.toolbar.Button(text, "inventario/22/" + btn.icon + ".png");
      if (btn.disabled) o.setEnabled(false);
      o.addListener("execute", callback, callback_ctxt);

      /*  Adjuntamos informacion privada al boton
             *   esto se usa como mecanismo de paso de datos entre el creador del boton y la llamada al callback
             */

      if (btn.priv_data)
      {
        for (var k in btn.priv_data) {
          o.setUserData(k, btn.priv_data[k]);
        }
      }

      // if (btn.tooltip) {
      // o.setToolTip(new qx.ui.popup.ToolTip(btn.tooltip));
      // }
      if (btn.nombre_boton)
      {
        var k = btn.nombre_boton;
        this.getArrayBotones()[k] = o;
      }

      return o;
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _escape_cb : function(e)
    {
      if (e.getKeyIdentifier() == "Escape")
      {
        if (this.getAskConfirmationOnClose())
        {
          if (confirm(qx.locale.Manager.tr("Close window?")))
          {
            this.getAbstractPopupWindow().getWindow().close();
          }
        }
        else
        {
          this.getAbstractPopupWindow().getWindow().close();
        }
      }
    },


    /**
     * TODOC
     *
     * @param value {var} TODOC
     * @return {void} 
     */
    _applyWindowTitle : function(value)
    {
      var win = this.getAbstractPopupWindow();

      if (win) {
        win.getWindow().setCaption(value);
      }
    }
  }
});
