
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
// QuestionForm.js
// Questionary Viewer for the system
// Author: Martin Abente ( tincho_02@hotmail.com | mabente@paraguayeduca.org )
// Paraguay Educa 2009
qx.Class.define("inventario.widget.QuestionForm",
{
  extend : qx.ui.container.Composite,

  /*
       * CONSTRUCTOR
       */

  construct : function(questionary)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.VBox(20));

      var mainScroll = new qx.ui.container.Scroll();

      mainScroll.set(
      {
        width  : 400,
        height : 250
      });

      var mainGrid = new qx.ui.container.Composite(new qx.ui.layout.Grid(5, 5));

      var qLen = questionary.length;

      for (var i=0; i<qLen; i++)
      {
        var question_id = questionary[i].question_id;
        var question_type = questionary[i].question_type;
        var question_text = questionary[i].question_text;
        var cb_options = questionary[i].cb_options;
        var comment = questionary[i].comment;

        var qWidget = new inventario.widget.QuestionField(question_id, question_type, question_text, cb_options, comment);

        // qWidget.set({decorator: "tabview-pane"});
        mainGrid.add(qWidget,
        {
          row    : i,
          column : 0
        });
      }

      mainScroll.add(mainGrid);
      this.add(mainScroll);

      this._mainGrid = mainGrid;
      this._qLen = qLen;
    }
    catch(e)
    {
      alert(e.toString());
    }
  },

  /*
       * MEMBERS
       */

  members :
  {
    /**
     * TODOC
     *
     * @return {var} TODOC
     */
    getValues : function()
    {
      var ret = [];

      var qLen = this._qLen;
      var mainGrid = this._mainGrid;

      for (var i=0; i<qLen; i++)
      {
        var cellWidget = mainGrid.getLayout().getCellWidget(i, 0);
        ret.push(cellWidget.getValues());
      }

      return ret;
    }
  }
});