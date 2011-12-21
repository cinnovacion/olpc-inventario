
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
    _createInputs : function() {
      throw new Error("createInputs is abstract");
    },

    getWindowIcon : function() {
      var icon = this.getAbstractPopupWindow().getIcon();
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

    _exitWindow : function() {
      throw new Error("_exitWindow() is abstract");
    },

    cerrar : function() {
      this.getAbstractPopupWindow().close();
    },

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

    doMaximize : function()
    {
      this.getAbstractPopupWindow().open();
    },

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
          w = new inventario.widget.Window(t);
          this.setAbstractPopupWindow(w);

          var height = this.getAbstractPopupWindowHeight();
          var width = this.getAbstractPopupWindowWidth();

          if (height > 0) {
            this.getAbstractPopupWindow().setHeight(height);
          }

          if (width > 0) {
            this.getAbstractPopupWindow().setWidth(width);
          }

          this.getAbstractPopupWindow().setModal(false);

          /* Manejar Esc. como cierre de ventana */

          this.getAbstractPopupWindow().addListener("keyup", this._escape_cb, this);

          // minimize to the application taskbar
          this.getAbstractPopupWindow().addListener("minimize", this._minimize_cb, this);
        }

        page = this.getAbstractPopupWindow().getVbox();
        inventario.widget.Layout.removeChilds(page);
        page.add(vbox);
		this.getAbstractPopupWindow().open();
        widgetAsociarKeys = this.getAbstractPopupWindow();
      }
      else
      {
        page = this.getPage();
        inventario.widget.Layout.removeChilds(page);
        page.add(vbox);
        widgetAsociarKeys = page;
      }

    },

    _minimize_cb : function()
    {
      var taskbar = inventario.widget.TaskBar.getInstance();
      taskbar.minimize(this);
    },

    _addAccelerator : function(key_str, func, obj)
    {
      var h = {};
      h["key"] = key_str;
      h["func"] = func;
      h["obj"] = obj;
      this.getAceleradores().push(h);
    },

    _doAddAccelerator : function(accel_key, callback, callback_ctxt, widgetAsociarKeys) {
      inventario.util.Keys.addAccelerator(accel_key, callback, callback_ctxt, widgetAsociarKeys);
    },

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

    _escape_cb : function(e)
    {
      if (e.getKeyIdentifier() == "Escape")
      {
        if (this.getAskConfirmationOnClose())
        {
          if (confirm(qx.locale.Manager.tr("Close window?")))
          {
            this.getAbstractPopupWindow().close();
          }
        }
        else
        {
          this.getAbstractPopupWindow().close();
        }
      }
    },

    _applyWindowTitle : function(value)
    {
      var win = this.getAbstractPopupWindow();

      if (win) {
        win.setCaption(value);
      }
    }
  }
});
