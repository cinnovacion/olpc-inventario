
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
// Wizard.js
// fecha: 2007-09-08
// autor: Raul Gutierrez S.
//
// Objetivo:
// - manejar navegacion entre varios descendientes de AbstractWindow (Cancelar,Anterior,Siguiente,Finalizar)
// - metodos para obtener toda la informacion y guardar
//
//
qx.Class.define("inventario.window.Wizard",
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
    this.setUsePopup(true);

    this.setPanelConfigs(new Array());
    this.setPanelObjs(new Array());
  },




  /*
    *****************************************************************************
       PROPERTIES
    *****************************************************************************
    */

  properties :
  {
    panelConfigs : { check : "Array" },
    panelObjs : { check : "Array" },

    existenInstancias :
    {
      check : "Boolean",
      init  : false
    },

    vbox : { check : "Object" },

    finalPanel :
    {
      check : "Object",
      init  : null
    },

    saveUrl :
    {
      check : "String",
      init  : ""
    },

    useFinalPanel :
    {
      check : "Boolean",
      init  : true
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
     * TODOC
     *
     * @param configHash {var} TODOC
     * @return {void} 
     * @throws TODOC
     */
    addPanel : function(configHash)
    {
      var keys = "clase";

      try
      {
        var v = keys.split(/,/);
        var len = v.length;

        for (var i=0; i<len; i++)
        {
          var k = v[i];

          if (!configHash[k]) {
            throw new Error("El hash debe contener la clave: " + k);
          }
        }

        this.getPanelConfigs().push(configHash);
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje(e);
      }
    },


    /**
     * TODOC
     *
     * @param v {var} TODOC
     * @return {void} 
     */
    addPanels : function(v)
    {
      var len = (v ? v.length : 0);

      for (var i=0; i<len; i++) {
        this.addPanel(v[i]);
      }
    },


    /**
     * show():
     *
     * @return {void} void
     */
    show : function()
    {
      var vbox = new qx.ui.layout.VerticalBoxLayout();
      vbox.setDimension("100%", "100%");
      this.setVbox(vbox);

      this.setPanelObjs(new Array());

      /* Creamos paneles */

      var paneles = this.getPanelConfigs();
      var len = paneles.length;

      for (var i=0; i<len; i++)
      {
        var clase = paneles[i]["clase"];
        var obj = new clase();
        obj.setPage(vbox);
        obj.setWizardMode(true);
        obj.setWizardPosition(i);
        obj.setWizardNumberOfPanels(len);
        obj.setWizardObj(this);

        /* establecer propiedades */

        if (paneles[i]["properties"])
        {
          for (var k in paneles[i]["properties"])
          {
            var val = paneles[i]["properties"][k];
            var evalStr = "obj.set" + k + "(" + val + ");";
            eval(evalStr);
          }
        }

        this.getPanelObjs().push(obj);
      }

      this.show2(0);
    },


    /**
     * show():
     *
     * @param panelNum {var} TODOC
     * @return {void} void
     */
    show2 : function(panelNum)
    {
      this._doShow2(this.getVbox());
      this.getPanelObjs()[panelNum].show(true);
    },


    /**
     * finalizePanel():
     *
     * @return {void} void
     */
    finalizePanel : function()
    {
      var p = this.getFinalPanel();

      if (!p)
      {
        p = new inventario.window.WizardFinalPanel();
        p.setWizardMode(true);
        p.setWizardPosition(this.getPanelConfigs().length);
        p.setWizardNumberOfPanels(this.getPanelConfigs().length);
        p.setWizardObj(this);
        this.setFinalPanel(p);
      }

      p.setPage(this.getVbox());

      var datos = new Array();

      /*
             * Obtener & pasar info
             */

      try
      {
        var objs = this.getPanelObjs();
        var len = objs.length;

        for (var i=0; i<len; i++)
        {
          var h = objs[i].getWindowData();
          datos.push(h);
        }

        p.setDatos(datos);
        p.show();
      }
      catch(e)
      {
        inventario.window.Mensaje.mensaje(e);
      }
    },


    /**
     * TODOC
     *
     * @param hOpts {Map} TODOC
     * @return {var} TODOC
     */
    getWizardPanel : function(hOpts)
    {
      var retPanel = null;

      if (hOpts["tag"])
      {
        var objs = this.getPanelObjs();
        var len = objs.length;

        for (var i=0; i<len; i++)
        {
          if (objs[i].getWizardPanelTag() == hOpts["tag"])
          {
            retPanel = objs[i];
            break;
          }
        }
      }

      return retPanel;
    }
  }
});