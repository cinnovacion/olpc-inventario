
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
// ObjectManager.js
// fecha: 2007-03-16
// autor: rgs
//
// Singleton p/ reciclar objetos
/**
 * Constructor
 *
 * @param param string
 */
qx.Class.define("inventario.util.ObjectManager",
{
  extend : qx.core.Object,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function() {},

  // llamar al constructor del padre
  /*
      *****************************************************************************
         STATICS
      *****************************************************************************
      */

  statics :
  {
    /**
     * getObject(): Retona el objeto (Abm2 de momento) solicitado. Si ya tenia retorna ese,sino crea una instancia.
     *
     * @param que {String} El identificador para inventario.widget.Url
     * @return {Object} TODOC
     */
    getObject : function(que)
    {
      var hopts = inventario.widget.getUrl(que);
      var retobj = inventario.util._doGetObject(que);

      if (!retobj)
      {
        retobj = new inventario.window.Abm2(null, hopts);

        /* cachear el objeto */

        inventario.util._saveObject(retobj);
      }

      return retobj;
    },


    /**
     * _doGetObject()
     *
     * @param que {String} El identificador para inventario.widget.Url
     * @return {Object} TODOC
     */
    getObject : function(que)
    {
      var objetos = inventario.util._objects;
      var len = objetos.length;
      var retobj = null;

      for (var i=0; i<len; i++)
      {
        if (objetos[i]["name"] == que)
        {
          retobj = objetos[i]["object"];
          break;
        }
      }

      return retobj;
    },


    /**
     * _saveObject()
     *
     * @param obj {Object} TODOC
     * @param name {String} nombre identificador del objeto
     * @return {void} 
     */
    _saveObject : function(obj, name)
    {
      var h = {};
      h["name"] = name;
      h["object"] = obj;
      inventario.util._objects.push(h);
    },

    _objects : new Array()
  }
});