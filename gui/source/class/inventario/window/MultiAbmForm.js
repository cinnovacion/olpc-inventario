
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
// MultiAbmForm.js
// fecha: 2007-07-25
// autor: Raul Gutierrez S.
//
//
/**
 * @param page {}  Puede ser null
 * @param oMethods {Hash}  hash de configuracion {searchUrl,initialDataUrl,...}
 * @return void
 */
qx.Class.define("inventario.window.MultiAbmForm",
{
  extend : inventario.window.AbstractWindow,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function(page, oMethods)
  {
    inventario.window.AbstractWindow.call(this, page);

    /* tamanho por default */

    this.setUsePopup(true);
    this.setAbstractPopupWindowHeight(510);
    this.setAbstractPopupWindowWidth(520);

    this.prepared = false;
  },




  /*
    *****************************************************************************
       PROPERTIES
    *****************************************************************************
    */

  properties :
  {

    /* Parametros funcionales */

    showSaveButton :
    {
      check : "Boolean",
      init  : true
    },

    showCloseButton :
    {
      check : "Boolean",
      init  : true
    },

    closeAfterInsert :
    {
      check : "Boolean",
      init  : true
    },

    windowPopup :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    editRow :
    {
      check : "Number",
      init  : 0
    },

    details :
    {
      check : "Boolean",
      init  : false
    },

    vista :
    {
      check : "String",
      init  : ""
    },

    /* Vector con hashes de configuracion, uno por pagina. Cada Hash contiene:
         * - titulo = Titulo de la pagina (pestanha)
         * - select = Parametro para asociar un objeto inventario.widget.Select a la pagina (boton ..)
         * - InitialDataUrl = de donde traer los datos del AbmForm
         * - SaveUrl = como guardar el formulario
         */

    abmFormConfigs :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /*
         *  RPC
         */

    initialDataUrl :
    {
      check : "String",
      init  : ""
    },

    saveUrl :
    {
      check : "String",
      init  : ""
    },

    /*
         * Callbacks
         */

    saveCallback :
    {
      check    : "Function",
      init     : null,
      nullable : true
    },

    saveCallbackObj :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /*
         * Widgets & icons
         */

    tabBar : { check : "Object" },

    windowIcon :
    {
      check : "String",
      init  : ""
    },

    vbox :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /* Objetos */

    abmFormPages :
    {
      check    : "Object",
      init     : null,
      nullable : true
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
     * show():
     *
     * @return {void} void
     */
    show : function()
    {
      if (!this.prepared)
      {

        /* Layout */

        this._createLayout();
        this.prepared = true;
      }

      this._doShow();
    },


    /**
     * _doShow()
     *
     * @return {void} void
     */
    _doShow : function()
    {
      var vbox = this.getVbox();

      this._doShow2(vbox);
      this.getTabBar().show();
    },

    // qx.ui.core.Widget.flushGlobalQueues();
    /*
         * Creamos una pagina (pestanha) por cada AbmForm
         *
         */

    /**
     * TODOC
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var vbox = new qx.ui.groupbox.GroupBox("Ingrese los siguientes datos");
      vbox.setDimension("100%", "100%");
      var abmObjs = new Array();
      var heightForm = "100%";
      var haySelect = false;

      /*
             * Contenedor de paginas
             */

      var hbox = new qx.ui.layout.HorizontalBoxLayout();
      hbox.setWidth("95%");
      hbox.setHeight("90%");
      var configs = this.getAbmFormConfigs();
      var len = (configs ? configs.length : 0);
      var tw = new inventario.widget.Tabwindow();
      var titems = new Array();

      for (var i=0; i<len; i++)
      {
        var hFormConfig = configs[i];
        var abmFormObjPage = new inventario.window.MultiAbmFormPage();
        abmFormObjPage.setConfig(hFormConfig);

        var h =
        {
          label : hFormConfig["titulo"],
          icon  : "icon/16/apps/office-organizer.png"
        };

        h["handler"] = abmFormObjPage.show;
        h["obj"] = abmFormObjPage;

        if (i == 0) {
          h["checked"] = true;
        }

        if (hFormConfig["showSelect"]) {
          haySelect = true;
        }

        titems.push(h);

        /* Guardamos el MultiAbmFormPage p/ poder guardar los datos dp */

        abmObjs.push(abmFormObjPage);
      }

      if (!haySelect) {
        this.setAddWindowHeight(480);
      }

      this.setAbmFormPages(abmObjs);

      tw.setTabItems(titems);
      tw.setPage(hbox);
      this.setTabBar(tw);

      vbox.add(hbox);

      /*
             * Barra de Acciones
             */

      /* Boton Guardar */

      var h =
      {
        type            : "button",
        icon            : "floppy_black",
        text            : "Guardar",
        callBackFunc    : this._saveData,
        callBackContext : this
      };

      this.getToolBarButtons().push(h);
      this.getToolBarButtons().push({ type : "separator" });

      /* Boton cerrar/salir */

      if (this.getUsePopup())
      {
        var f = function(e) {
          this.getAbstractPopupWindow().getWindow().close();
        };

        var h =
        {
          type            : "button",
          icon            : "stop",
          text            : "Cerrar",
          callBackFunc    : f,
          callBackContext : this
        };

        this.getToolBarButtons().push(h);
      }

      vbox.add(this._buildCommandToolBar(false, 2));

      // vbox.add(this._buildCommandToolBar(false));
      // vbox.add(hbox);
      // gb.add(vbox);
      // gb.add(this._buildCommandToolBar(false));
      this.setVbox(vbox);
    },

    /*
         * Guardar datos
         *
         * Habria que encontrar un mecanismo para encolar las llamadas.. Voy a tener problemas si disparo mas de 2 llamadas de una (limite de HTTP)
         */

    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _saveData : function(e)
    {
      this._savingAbmNum = 0;
      this._doSaveData();
    },


    /**
     * TODOC
     *
     * @param newData {var} TODOC
     * @param remoteData {var} TODOC
     * @return {void} 
     */
    _doSaveData : function(newData, remoteData)
    {
      var abms = this.getAbmFormPages();
      var i = this._savingAbmNum;
      this._savingAbmNum++;

      if (this._savingAbmNum <= abms.length && abms[i].getAbmFormObj()) {
        abms[i].getAbmFormObj().saveData(this._doSaveData, this);
      }
      else
      {
        var f = this.getSaveCallback();
        var obj = this.getSaveCallbackObj();

        if (f)
        {
          obj = (obj ? obj : this);
          f.call(obj, newData, remoteData);
        }
        else
        {
          inventario.window.Mensaje.mensaje("Sus datos han sido guardados");
        }

        /*
                 * Cerrar ventana?
                 */

        if (this.getUsePopup() && this.getCloseAfterInsert()) {
          this.getAbstractPopupWindow().getWindow().close();
        }
      }
    }
  }
});