
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
/* ************************************************************************

   qooxdoo - the new era of web development

   http://qooxdoo.org

   License:
     LGPL 2.1: http://www.gnu.org/licenses/lgpl.html

   Authors:
     * Kaoru Uchiaymada

************************************************************************ */

/* ************************************************************************


************************************************************************ */

/**
 * A data cell renderer for boolean values.
 */
qx.Class.define("inventario.qooxdoo.ListDataCellRenderer",
{
  extend : qx.ui.table.cellrenderer.Abstract,




  /*
    *****************************************************************************
       CONSTRUCTOR
    *****************************************************************************
    */

  construct : function() {
    qx.ui.table.cellrenderer.Abstract.call(this);
  },




  /*
    *****************************************************************************
       MEMBERS
    *****************************************************************************
    */

  members :
  {
    // overridden
    /**
     * TODOC
     *
     * @param cellInfo {var} TODOC
     * @return {var} TODOC
     */
    _getCellStyle : function(cellInfo)
    {
      var style = qx.ui.table.cellrenderer.Abstract.prototype._getCellStyle(cellInfo);
      style += ';text-align:center;padding-top:1px';
      return style;
    },

    // overridden
    /**
     * TODOC
     *
     * @param cellInfo {var} TODOC
     * @return {var} TODOC
     */
    _getContentHtml : function(cellInfo)
    {
      var input = cellInfo.value;
      return input.text;
    },

    // overridden
    /**
     * TODOC
     *
     * @param cellInfo {var} TODOC
     * @param cellElement {var} TODOC
     * @return {void} 
     */
    updateDataCellElement : function(cellInfo, cellElement) {
      cellElement.innerHTML = this._getContentHtml(cellInfo);
    }
  }
});