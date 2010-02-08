
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
// RemoteParser.js:
// - carga de campos,etc.
//
// fecha: 2007-02-20
// autor: Raul Gutierrez S.
//
/**
 *  Todo es static por aqui....
 *
 * @return void
 */
qx.Class.define("inventario.parser.RemoteParser",
{
  extend : qx.core.Object,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function() {},




  /*
      *****************************************************************************
         STATICS
      *****************************************************************************
      */

  statics :
  {
    /**
     * loadInputs():
     *
     * @param remoteHash {var} hash con inputs y values
     * @param ctxt {var} contexto (this del caller normalmente)
     * @return {void} void
     *     
     *        TODO: hay que poder manejar multiples input (TextField,ComboBox,etc.)
     */
    loadInputs : function(remoteHash, ctxt)
    {
      for (var k in remoteHash)
      {
        var val = remoteHash[k];
        var str = "ctxt.get" + k + "()";
        var input = eval(str);

        try
        {
          if (k.match(/Combo/)) {
            inventario.widget.Form.setComboBox(input, val);
          } else {
            input.setValue(val);
          }
        }
        catch(e) {}
      }
    }
  }
});