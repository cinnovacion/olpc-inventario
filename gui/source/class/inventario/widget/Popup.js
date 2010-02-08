
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
// Popup.js
// fecha: 2007-03-1
// autor: Kaoru Uchiyamada
//
// Crear un pop up de abm
//
//
// EN DESUSO
//
// Esto ya no tiene sentido porque AbstractWindow provee esta funcionalidad (rgs - 2007/08/14)
//
/**
 * @param param string para mandarle a geturl
 * @return void
 */
qx.Class.define("inventario.widget.Popup",
{
  extend : qx.core.Object,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function(param)
  {
    qx.core.Object.call(this);

    var url = inventario.widget.Url.getUrl(param);
    var abm = new inventario.window.Abm2(null, url);
    this.setAbm(abm);
    abm.setUsePopup(true);
    abm.setWithChooseButton(true);
    abm.setPaginated(true);
    abm.setRefreshOnShow(false);
  },




  /*
      *****************************************************************************
         PROPERTIES
      *****************************************************************************
      */

  properties :
  {
    window :
    {
      check    : "Object",
      init     : null,
      nullable : true
    },

    abm :
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
     * TODOC
     *
     * @return {void} 
     */
    show : function() {
      this.getAbm().show();
    }
  }
});