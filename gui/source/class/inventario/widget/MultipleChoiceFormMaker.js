
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
// MultipleChoiceFormMaker.js
// Dynamic Form for Multiple choice quizzes.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Paraguay Educa 2009
qx.Class.define("inventario.widget.MultipleChoiceFormMaker",
{
  extend : qx.ui.container.Composite,

  /*
       * CONSTRUCTOR
       */

  construct : function(questions)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.VBox(20));

      var scrollContainer = new qx.ui.container.Scroll();

      scrollContainer.set(
      {
        width  : 400,
        height : 250
      });

      var questionsGrid = new qx.ui.container.Composite(new qx.ui.layout.Grid(10, 10));

      var qLen = questions.length;

      for (var i=0; i<qLen; i++) {
        this._addQuestion(questionsGrid, i, questions[i]);
      }

      var addButton = new qx.ui.form.Button("Agregar Pregunta");
      addButton.setAllowGrowX(false);
      addButton.setAllowGrowY(false);
      addButton.addListener("execute", this._doAddQuestion, this);

      scrollContainer.add(questionsGrid);
      this.add(scrollContainer);
      this.add(addButton);

      this._questionsGrid = questionsGrid;
      this._questionsLen = qLen;
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

      var qLen = this._questionsLen;

      for (var i=0; i<qLen; i++)
      {
        var qWidget = this._questionsGrid.getLayout().getCellWidget(i, 0);

        var question = qWidget.getValues();
        question.id = qWidget.getUserData("id");

        ret.push(question);
      }

      return ret;
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _removeQuestion : function(e)
    {
      var index = this._questionsGrid.indexOf(e.getTarget()) - 1;

      for (var i=0; i<2; i++) {
        this._questionsGrid.removeAt(index);
      }

      this._questionsLen--;
    },


    /**
     * TODOC
     *
     * @param questionsGrid {var} TODOC
     * @param index {var} TODOC
     * @param question {var} TODOC
     * @return {void} 
     */
    _addQuestion : function(questionsGrid, index, question)
    {
      var qWidget = new inventario.widget.MultipleChoiceFieldMaker(question.text, question.options);
      qWidget.setUserData("id", question.id);

      var removeButton = new qx.ui.form.Button("Quitar Pregunta");
      removeButton.setAllowGrowX(false);
      removeButton.setAllowGrowY(false);
      removeButton.addListener("execute", this._removeQuestion, this);

      questionsGrid.add(qWidget,  /* .set({decorator: "tabview-pane"}) */
      {
        row    : index,
        column : 0
      });

      questionsGrid.add(removeButton,
      {
        row    : index,
        column : 1
      });
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _doAddQuestion : function()
    {
      this._addQuestion(this._questionsGrid, this._questionsLen,
      {
        id      : -1,
        text    : "",
        options : []
      });

      this._questionsLen++;
    }
  }
});