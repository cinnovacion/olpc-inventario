
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
// MultiAbmFormPage.js
// fecha: 2007-07-25
// autor: Raul Gutierrez S.
//
//
/**
 * @param page {}  Puede ser null
 * @param oMethods {Hash}  hash de configuracion {searchUrl,initialDataUrl,...}
 * @return void
 */
qx.Class.define("inventario.window.MultiAbmFormPage",
{
  extend : inventario.window.AbstractWindow,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function(page, oMethods) {
    inventario.window.AbstractWindow.call(this, page);
  },




  /*
    *****************************************************************************
       PROPERTIES
    *****************************************************************************
    */

  properties :
  {

    /* Parametros funcionales */

    config :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    abmFormObj :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    /*
         * Widgets & icons
         */

    vbox :
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
      var abmFormObj = this.getAbmFormObj();

      if (!abmFormObj) {
        this._createLayout();
      } else {
        this._doShow();
      }
    },


    /**
     * _doShow()
     *
     * @return {void} void
     */
    _doShow : function()
    {
      var vbox = this.getVbox();
      var page = this.getPage();
      inventario.widget.Layout.removeChilds(page);
      page.add(vbox);
      this.getAbmFormObj().show();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _createLayout : function()
    {
      var vbox = new qx.ui.layout.VerticalBoxLayout();
      vbox.setDimension("100%", "100%");
      var config = this.getConfig();
      var heightForm = "100%";

      /* Barra con Select.
             * TODO: Capturar el cambio en este Select para cargar el formulario. */

      if (config["showSelect"])
      {
        heightForm = "90%";
        var hbox = new qx.ui.layout.HorizontalBoxLayout();
        hbox.setWidth("100%");
        hbox.setHeight("10%");
        var label = new qx.ui.basic.Label("Buscar: ");
        hbox.setHorizontalChildrenAlign("center");
        var s = new inventario.widget.Select(config["select"]);
        s.setWidth("50%");
        hbox.add(label, s);

        vbox.add(hbox);
      }

      /* Barra separadora */

      vbox.add(new qx.ui.basic.Terminator());

      /* Formulario */

      var hbox = new qx.ui.layout.HorizontalBoxLayout();
      hbox.setWidth("100%");
      hbox.setHeight(heightForm);
      hbox.setHorizontalChildrenAlign("center");
      var abmFormObj = new inventario.window.AbmForm(null, {});
      var url = config["InitialDataUrl"];
      abmFormObj.setInitialDataUrl(url);
      var url = config["SaveUrl"];
      abmFormObj.setSaveUrl(url);
      abmFormObj.setUsePopup(false);
      abmFormObj.setShowSaveButton(false);
      abmFormObj.setShowCloseButton(false);
      abmFormObj.setPage(hbox);

      /* Ediciones */

      if (config["id"]) {
        abmFormObj.setEditRow(config["id"]);
      }

      this.setAbmFormObj(abmFormObj);

      vbox.add(hbox);

      this.setVbox(vbox);
      this._doShow();
    }
  }
});