
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
// Tree.js
// fecha: 2006-11-22
// autor: Raul Gutierrez S. - rgs@fuzzylogic.com.py
//
// Manipulacion de Trees
qx.Class.define("inventario.widget.Tree",
{
  extend : qx.core.Object,

  construct : function() {},

  // llamar al constructor del padre

  statics :
  {
    /**
     * Para saber que esta seleccionado en un tree (que tiene nodos con checkboxes)
     *
     * @param tree {qx.ui.tree.Tree} el tree
     * @param key {var} {} lo que almacenamos para retornar
     * @return {Array} vector de keys de nodos seleccionados
     *   
     *      TODO: solo funcionan con arboles de 2 jerarquias.. habria que hacerlo de forma recursiva
     */
    getSelected : function(tree, key)
    {
      var ret = new Array();
      var nodos = tree.getChildren()[1].getChildren();
      var len = nodos.length;

      for (var i=0; i<len; i++)
      {

        /* Esto es porque cada Elemento del arbol tiene un hijo Hbox y un Hijo Vbox */

        var menuCheckBox = null;

        try {
          menuCheckBox = nodos[i].getChildren()[0].getChildren()[1];
        } catch(e) {}

        var submenus = nodos[i].getChildren()[1].getChildren();
        var len2 = submenus.length;

        for (var j=0; j<len2; j++)
        {
          var v = submenus[j].getUserData(key);

          if (v)
          {
            try
            {

              /* habilitar el menu padre */

              var f = submenus[j]._treeRowStructureFields;

              for (var k=0; k<f.length; k++)
              {
                if (f[k] instanceof qx.ui.form.CheckBox)
                {
                  if (f[k].getValue())
                  {
                    ret.push(v);
                    break;
                  }
                }
              }
            }
            catch(e) {}
          }
        }
      }

      return ret;
    }
  }
});
