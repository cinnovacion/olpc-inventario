
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
// QuestionField.js
// A simple widget for showing a question from the quiz maker app.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Paraguay Educa 2009
qx.Class.define("inventario.widget.QuestionField",
{
  extend : qx.ui.container.Composite,

  /*
       * CONSTRUCTOR
       */

  construct : function(question_id, question_type, question_text, cb_options, comment)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.VBox(20));
      this.set({ width : 300 });

      this._question_id = question_id;
      this._question_type = question_type;
      this._checkBoxes = null;
      this._textField = null;
      var input = null;

      var questionLabel = new qx.ui.basic.Label().set(
      {
        content : "<b>" + question_text.toString() + "</b>",
        rich    : true,
        width   : 120
      });

      if (question_type == "multiple_choice") {
        input = this._checkBoxes = new inventario.widget.CheckboxSelector("", cb_options, 1);
      } else {
        input = this._textField = new qx.ui.form.TextField(comment.toString());
      }

      this.add(questionLabel);
      this.add(input);
    }
    catch(e)
    {
      alert(e.toString());
    }
  },

  /*
       * PROPERTIES
       */

  properties : {},

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
      var ret = {};
      ret.question_id = this._question_id;

      if (this._question_type == "multiple_choice")
      {
        ret.question_type = "multiple_choice";
        ret.values = this._checkBoxes.getSelectedParts();
      }
      else
      {
        ret.question_type = "text_field";
        ret.values = this._textField.getValue();
      }

      return ret;
    }
  }
});