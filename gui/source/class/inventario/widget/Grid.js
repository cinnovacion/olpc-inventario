
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
// Grid.js
// fecha: 2006-11-24
// autor: Raul Gutierrez S. - rgs@fuzzylogic.com.py
//
// helpers p/ GridLayout
//
qx.Class.define("inventario.widget.Grid",
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
     * createGridLayout   (metodo auxiliar p/ gridlayouts de la cabecera)
     *
     * @param rowCount {var} numero de filas
     * @param colCount {var} numero de columnas
     * @param options {var} hash de opciones { width,height,colArrayWidth }
     * @return {var} void
     */
    createGridLayout : function(rowCount, colCount, options)
    {
      var gl = new qx.ui.layout.GridLayout;
      gl.setLocation(0, 0);
      gl.setDimension(options["width"], options["height"]);

      // gl.setBorder("outset");
      gl.setPadding(1);
      gl.setColumnCount(colCount);
      gl.setRowCount(rowCount);
      gl.setColumnHorizontalAlignment(0, "left");
      gl.setColumnVerticalAlignment(0, "middle");
      gl.setVerticalSpacing(1);
      gl.setCellPaddingLeft(1);

      /*
                gl.setCellPaddingTop(1);
                gl.setCellPaddingRight(1);
                gl.setCellPaddingBottom(1);
            */

      for (var i=0; i<rowCount; i++) {
        gl.setRowHeight(i, 24);
      }

      for (var i=0; i<colCount; i++) {
        gl.setColumnWidth(i, options["colArrayWidth"][i]);
      }

      return gl;
    },


    /**
     * addGridRow  : agregar fila a un gridlayout
     *
     * @param label {var} label
     * @param gridLayout {var} TODOC
     * @param row {var} fila a la cual agregar
     * @param inputTypeClass {var} referencia a la clase que se quieren instanciar
     * @return {var} input
     */
    addGridRow : function(label, gridLayout, row, inputTypeClass)
    {
      var l = new qx.ui.basic.Atom(label);
      var retInput = new inputTypeClass;
      gridLayout.add(l, 0, row);
      gridLayout.add(retInput, 1, row);

      return retInput;
    },


    /**
     * addGridRow2  : agregar fila a un gridlayout
     *
     * @param label {var} label
     * @param gridLayout {var} TODOC
     * @param row {var} fila a la cual agregar
     * @param inputTypeClass {var} referencia a la clase que se quieren instanciar
     * @param startCol {var} TODOC
     * @return {var} input
     */
    addGridRow2 : function(label, gridLayout, row, inputTypeClass, startCol)
    {
      var l = new qx.ui.basic.Atom(label);
      var retInput = new inputTypeClass;
      gridLayout.add(l, startCol, row);
      gridLayout.add(retInput, startCol + 1, row);

      return retInput;
    }
  }
});