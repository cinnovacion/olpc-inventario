
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
// ReportGeneratorExtensions.js
// Extensions for Report Generator...
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguay.org)
// Paraguay Educa 2009
qx.Class.define("inventario.report.ReportGeneratorExtensions",
{
  extend : qx.core.Object,

  construct : function() {},

  statics :
  {
    launch : function(label, options)
    {
      var report = new inventario.report.ReportGenerator(options.option, label);
      report.launch();
    }
  }
});
