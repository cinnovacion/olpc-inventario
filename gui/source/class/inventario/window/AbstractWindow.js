
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
/**
 * Constructor
 *
 * @param page {}  Puede ser null
 */
qx.Class.define("inventario.window.AbstractWindow",
{
  extend : qx.core.Object,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function(page)
  {
    if (page) {
      this.setPage(page);
    }

    var o = new Array();
    this.setInputsOM(o);
    var o = new Array();
    this.setToolBarButtons(o);

    /* Manejo de abreviaciones de teclado */

    var o = new inventario.util.ObjectManager();
    this.setCommandsManager(o);

    var v = new Array();
    this.setAceleradores(v);
  },




  /*
    *****************************************************************************
       PROPERTIES
    *****************************************************************************
    */

  properties :
  {
    page :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /* Datos para crear los botones p/ la barra de comandos */

    toolBarButtons :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /* Barra de Comandos */

    toolBar :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /*
         *  Aca guardamos un hash de inputs p/ hacer mas facil la recoleccion y el envio de datos: { name, inputObj,value }
         *
         *  Observacion: inputObj y value son mutamente excluyentes. No se si eso es una buena idea. Tal vez sea mejor
         *               mantener siempre una copia de la propiedad sin formateos (el dato integro)
         */

    inputsOM : { check : "Object" },

    /* Metodo de salida. Llamar a este,si existe, cuando esta pantalla termine */

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

    /* Datos varios */

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

    /* Contador de veces de llamadas a doShow2. Sirve p/ profiling y tambien
        * para hacer algunas cosas solo la primera vez que se muestra la ventana
        */

    doShowCnt :
    {
      check : "Number",
      init  : 0
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

    /* saber si hubo cambios en la pantalla */

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

    wizardPanelTag :
    {
      check : "String",
      init  : ""
    },

    wizardMode :
    {
      check : "Boolean",
      init  : false
    },

    wizardPosition : { check : "Number" },
    wizardObj : { check : "Object" },
    wizardNumberOfPanels : { check : "Number" },

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




  /*
    *****************************************************************************
       MEMBERS
    *****************************************************************************
    */

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
    getWindowIcon : function()
    {
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
     * _returnToParentObject():  ver si hay un objeto padre asociado y entonces retornar a el invocando un metodo suyo.
     *
     * @return {void} 
     */
    _returnToParentObject : function()
    {
      var f = this.getExitCallback();

      if (f)
      {
        var ctxt = this.getExitCallbackContext();
        f.call(ctxt ? ctxt : this);
      }
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

    /*  _addCombo(): Agregar un ComboBox. Genera la Propiedad.
         *  @param rpc_property_name {String}  nombre del key para el valor del input que sera enviado en un hash al servidor
         *  @param obj_name {String} nombre del property (camel case, letra inicial mayuscula)
         *  @param addToInputsOM  {Boolean} agregar al vector de inputs que seran enviados al servidor?
         *  @param validationMsg  {String}
         *  @param extra          {Hash}  Con parametros que no se me ocurrieron a la hora de disenhar el API :)
         */

    /**
     * TODOC
     *
     * @param rpc_property_name {var} TODOC
     * @param obj_name {var} TODOC
     * @param addToInputsOM {var} TODOC
     * @param validationMsg {var} TODOC
     * @param extra {var} TODOC
     * @return {void} 
     */
    _addCombo : function(rpc_property_name, obj_name, addToInputsOM, validationMsg, extra)
    {
      var combo = (extra && extra["combo_box"]) ? extra["combo_box"] : new qx.ui.form.SelectBox();

      if (validationMsg && typeof (validationMsg) == "string" && validationMsg != "")
      {
        var f = function(cb, msg) {
          return inventario.widget.Form.getInputValueValidated(cb, msg, "combobox", "");
        };

        combo.setUserData("validation_func", f);
        combo.setUserData("validation_msg", validationMsg);
        combo.setUserData("validation_self_ref", combo);
      }

      this._doAddInput(rpc_property_name, obj_name, combo, addToInputsOM);
    },

    /*  _addCalendar(): Agregar un Calendario
         *  @param rpc_property_name {String}  nombre del key para el valor del input que sera enviado en un hash al servidor
         *  @param obj_name {String} nombre del property (camel case, letra inicial mayuscula)
         *  @param addToInputsOM  {Boolean} agregar al vector de inputs que seran enviados al servidor?
         *  @param validationMsg  {String}
         *  @param regex  {String}
         */

    /**
     * TODOC
     *
     * @param rpc_property_name {var} TODOC
     * @param obj_name {var} TODOC
     * @param addToInputsOM {var} TODOC
     * @param validationMsg {var} TODOC
     * @param regex {var} TODOC
     * @return {void} 
     */
    _addCalendar : function(rpc_property_name, obj_name, addToInputsOM, validationMsg, regex)
    {
      var input = new qx.ui.form.DateField();
      this._doAddInput(rpc_property_name, obj_name, input, addToInputsOM);
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
     * _addTextField(): Agregar un TextField
     *
     * @param rpc_property_name {String} nombre del key para el valor del input que sera enviado en un hash al servidor
     * @param obj_name {String} nombre del property (camel case, letra inicial mayuscula)
     * @param addToInputsOM {Boolean} agregar al vector de inputs que seran enviados al servidor?
     * @param validationMsg {String} TODOC
     * @param regex {String} TODOC
     * @param extra {Hash} Con parametros que no se me ocurrieron a la hora de disenhar el API :)
     * @return {void} 
     */
    _addTextField : function(rpc_property_name, obj_name, addToInputsOM, validationMsg, regex, extra)
    {
      var input = (extra && extra["text_field"]) ? extra["text_field"] : new inventario.qooxdoo.TextField();
      this._addText(rpc_property_name, obj_name, input, addToInputsOM, validationMsg, regex);
    },


    /**
     * _addPasswordField
     *
     * @param rpc_property_name {var} TODOC
     * @param obj_name {var} TODOC
     * @param addToInputsOM {var} TODOC
     * @param validationMsg {var} TODOC
     * @param regex {var} TODOC
     * @param extra {var} TODOC
     * @return {void} 
     */
    _addPasswordField : function(rpc_property_name, obj_name, addToInputsOM, validationMsg, regex, extra)
    {
      var input = (extra && extra["text_field"]) ? extra["text_field"] : new qx.ui.form.PasswordField();
      this._addText(rpc_property_name, obj_name, input, addToInputsOM, validationMsg, regex);
    },

    /*  _addTextArea(): Agregar un TextArea
         *  @param rpc_property_name {String}  nombre del key para el valor del input que sera enviado en un hash al servidor
         *  @param obj_name {String} nombre del property (camel case, letra inicial mayuscula)
         *  @param addToInputsOM  {Boolean} agregar al vector de inputs que seran enviados al servidor?
         *  @param validationMsg  {String}
         *  @param regex  {String}
         */

    /**
     * TODOC
     *
     * @param rpc_property_name {var} TODOC
     * @param obj_name {var} TODOC
     * @param addToInputsOM {var} TODOC
     * @param validationMsg {var} TODOC
     * @param regex {var} TODOC
     * @return {void} 
     */
    _addTextArea : function(rpc_property_name, obj_name, addToInputsOM, validationMsg, regex)
    {
      var input = new qx.ui.form.TextArea();

      if (validationMsg && regex) {
        this._addText(rpc_property_name, obj_name, input, addToInputsOM, validationMsg, regex);
      } else {
        this._doAddInput(rpc_property_name, obj_name, input, addToInputsOM);
      }
    },

    /*  _addCheckBox(): Agregar un Checkbox
         *  @type member
         *  @param rpc_property_name {String}  nombre del key para el valor del input que sera enviado en un hash al servidor
         *  @param obj_name {String} nombre del property (camel case, letra inicial mayuscula)
         *  @param addToInputsOM  {Boolean} agregar al vector de inputs que seran enviados al servidor?
         * @return {void}
         */

    /**
     * TODOC
     *
     * @param rpc_property_name {var} TODOC
     * @param obj_name {var} TODOC
     * @param addToInputsOM {var} TODOC
     * @return {void} 
     */
    _addCheckBox : function(rpc_property_name, obj_name, addToInputsOM)
    {
      var input = new qx.ui.form.CheckBox();
      this._doAddInput(rpc_property_name, obj_name, input, addToInputsOM);
    },


    /**
     * Pre-Wrapper sobre _doAddInput() que se encarga de establecer parametros de validacion
     *
     * @param rpc_property_name {var} TODOC
     * @param obj_name {var} TODOC
     * @param input {var} TODOC
     * @param addToInputsOM {var} TODOC
     * @param validationMsg {var} TODOC
     * @param regex {var} TODOC
     * @return {void} 
     */
    _addText : function(rpc_property_name, obj_name, input, addToInputsOM, validationMsg, regex)
    {
      if (validationMsg && validationMsg != "")
      {
        var f = function(iref, msg, freg) {
          return inventario.widget.Form.getInputValueValidated(iref, msg, "text", freg);
        };

        input.setUserData("validation_func", f);
        input.setUserData("validation_msg", validationMsg);
        input.setUserData("validation_self_ref", input);
        input.setUserData("validation_regex", (regex) ? regex : "[^(^ *$)]");
      }

      this._doAddInput(rpc_property_name, obj_name, input, addToInputsOM);
    },

    /*  _addInput(): Agregar un input
         *  @param rpc_property_name {String}  nombre del key para el valor del input que sera enviado en un hash al servidor
         *  @param obj_name {String} nombre del property (camel case, letra inicial mayuscula)
         *  @param input {Object} referencia al input
         *  @param addToInputsOM  {Boolean} agregar al vector de inputs que seran enviados al servidor?
         */

    /**
     * TODOC
     *
     * @param rpc_property_name {var} TODOC
     * @param obj_name {var} TODOC
     * @param input {var} TODOC
     * @param addToInputsOM {var} TODOC
     * @return {void} 
     */
    _doAddInput : function(rpc_property_name, obj_name, input, addToInputsOM)
    {
      input.setUserData("rpc_property_name", rpc_property_name);
      var eval_str = "this.set" + obj_name + "(input)";
      eval(eval_str);

      if (addToInputsOM) {
        this.getInputsOM().push(input);
      }
    },

    /*  _getInputsHash(): obtiene un hash de keys (rpc_property_name) a partir de lo que haya en el InputsOM y sus funciones de validacion
         *
         * TODO: Manejar caso de un grupo de checkboxes
         */

    /**
     * TODOC
     *
     * @return {var} TODOC
     * @throws TODOC
     */
    _getInputsHash : function()
    {
      var inputs = this.getInputsOM();
      var len = inputs.length;
      var ret = {};
      var n = "";

      for (var i=0; i<len; i++)
      {
        try
        {
          var input = inputs[i];
          n = input.getUserData("rpc_property_name");

          if (input instanceof qx.ui.form.CheckBox) {
            ret[n] = input.getChecked();
          } else if (input instanceof qx.ui.form.DateField) {
            ret[n] = input.getTextField().getValue();
          }
          else
          {
            //                var n = input.getUserData("rpc_property_name");
            var f = input.getUserData("validation_func");
            var vm = input.getUserData("validation_msg");
            var obj = input.getUserData("validation_self_ref");
            var re = input.getUserData("validation_regex");
            ret[n] = f.call(this, obj, vm, re);

            /* convertir formato de nro. nuestro al americano que manejan Ruby & MySQL */

            if (input.getUserData("desformatear_numero") && input.getUserData("desformatear_numero") == "si") {
              ret[n] = inventario.widget.Form.unFormatNumber(ret[n]);
            }
          }
        }
        catch(e)
        {
          // Usar esto cuando todo esta estable
          throw new Error(e + " " + n);
        }
      }

      // Usar esto para depurar
      // throw new Error("getInputsHash(): Error al procesar el input:" + n + "," + e);
      return ret;
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

      with (tb)
      {
        if (!distancia) distancia = 10;

        if (!arriba) {
          setBottom(distancia);
        }
      }

      /*
             * Boton anterior
             */

      if (this.getWizardMode() && this.getWizardPosition() > 0)
      {
        var iAnterior = this.getWizardPosition() - 1;

        var callback = function() {
          this.show2(iAnterior);
        };

        var callback_ctxt = this.getWizardObj();

        var h =
        {
          text           : "Anterior",
          icon           : "back",
          accel_keyboard : "Control+Left"
        };

        var o = this._doAddToolbarButton(h, callback, callback_ctxt);
        tb.add(o);
      }

      // ceramos hash de botones
      this.setArrayBotones({});

      for (var i=0; i<btns.length; i++)
      {
        var btn = btns[i];
        var callback = btn.callBackFunc;
        var callback_ctxt = btn.callBackContext;

        switch(btn.type)
        {
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

      /*
             * Boton siguiente
             *
             */

      if (this.getWizardMode())
      {
        if (this.getWizardPosition() < (this.getWizardNumberOfPanels() - 1))
        {
          var iSiguiente = this.getWizardPosition() + 1;

          var callback = function()
          {
            try
            {
              this.getWindowData();
              this.getWizardObj().show2(iSiguiente);
            }
            catch(e)
            {
              inventario.window.Mensaje.mensaje(e);
            }
          };

          var callback_ctxt = this;

          var h =
          {
            text           : "Siguiente",
            icon           : "forward",
            accel_keyboard : "Control+Right"
          };

          var o = this._doAddToolbarButton(h, callback, callback_ctxt);
          tb.add(o);
        }
        else if (this.getWizardPosition() == (this.getWizardNumberOfPanels() - 1))
        {

          /* Boton finalizar */

          if (this.getWizardObj().getUseFinalPanel())
          {
            var callback = function()
            {
              try
              {
                this.getWindowData();
                this.getWizardObj().finalizePanel();
              }
              catch(e)
              {
                inventario.window.Mensaje.mensaje(e);
              }
            };

            var callback_ctxt = this;

            var h =
            {
              text           : "<u>F</u>inalizar",
              icon           : "ok",
              accel_keyboard : "Control+F"
            };

            var o = this._doAddToolbarButton(h, callback, callback_ctxt);
            tb.add(o);
          }
        }
      }

      this.setToolBar(tb);

      return tb;
    },


    /**
     * TODOC
     *
     * @param widgetAsociarKeys {Object} widget al cual asociamos la captura de teclas
     * @return {void} 
     */
    _associateKeys : function(widgetAsociarKeys)
    {
      var btns = this.getToolBarButtons();

      /*
             *  Activar aceleradores de la barra
             */

      for (var i=0; i<btns.length; i++)
      {
        var btn = btns[i];
        var callback = btn.callBackFunc;
        var callback_ctxt = btn.callBackContext;

        switch(btn.type)
        {
          case "button":
            var text = btn.text;

            if (btn.accel_keyboard) {
              this._doAddAccelerator(btn.accel_keyboard, callback, callback_ctxt, widgetAsociarKeys);
            }

            break;
        }
      }

      /*
             * Activar aceleradores de los inputs (Select,TextFields,etc.)
             */

      var v = this.getAceleradores();
      var len = (v ? v.length : 0);

      for (var i=0; i<len; i++) {
        this._doAddAccelerator(v[i]["key"], v[i]["func"], v[i]["obj"], widgetAsociarKeys);
      }
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
     * @return {var} TODOC
     */
    searchButton : function(label)
    {
      var vecButtons = new Array();
      var ret = null;

      vecButtons = this.getToolBar().getAllButtons();

      for (var i=0; i<vecButtons.length; i++)
      {
        if (vecButtons[i].getLabel() = label) ret = vecButtons[i];
      }

      return ret;
    },

    /* TODO: implementar esto.. */

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

      /* Habilitar botones */

      //this.getCommandsManager().enableAll();

      /* Deshabilitar comandos al salir */

      var cnt = this.getDoShowCnt();

      if (!cnt)
      {
        /*
        	 * Activamos los aceleradores..
        	 */

        this._associateKeys(widgetAsociarKeys);
      }

      cnt++;
      this.setDoShowCnt(cnt);
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

    /*
         *
         *
         */

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

    /* doAddAccelerator():
         * @param accel_key {String} Cadena del acelerador (ej. Control+A)
         * @param callback {function} callback
         * @param callback_ctxt {object} contexto del callback
         * @param widgetAsociarKeys {object} widget al cual asociamos el evento
         * @return {void}
         *  asociar combinacion de teclas a una funcion
         */

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
          if (confirm("Cerrar ventana?"))
          {
            this.getCommandsManager().disableAll();
            this.getAbstractPopupWindow().getWindow().close();
          }
        }
        else
        {
          this.getCommandsManager().disableAll();
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
