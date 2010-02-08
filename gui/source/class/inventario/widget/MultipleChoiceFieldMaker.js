
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
// MultipleChoiceFieldMaker.js
// Dynamic Generation of a Mutiple choice field.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Paraguay Educa 2009
qx.Class.define("inventario.widget.MultipleChoiceFieldMaker",
{
  extend : qx.ui.container.Composite,

  /*
       * CONSTRUCTOR
       */

  construct : function(text, options)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.VBox(20));

      var questionText = new qx.ui.form.TextField(text.toString());
      questionText.setWidth(150);

      var optionsGrid = new qx.ui.container.Composite(new qx.ui.layout.Grid(0, 5));
      var optLen = options.length;

      for (var i=0; i<optLen; i++) {
        this._addOption(optionsGrid, i, options[i]);
      }

      var addButton = new qx.ui.form.Button("Agregar Opcion");
      addButton.setAllowGrowX(false);
      addButton.setAllowGrowY(false);
      addButton.addListener("execute", this._doAddOption, this);

      this.add(questionText);
      this.add(optionsGrid);
      this.add(addButton);

      this._questionText = questionText;
      this._optionsLen = optLen;
      this._optionsGrid = optionsGrid;
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
      ret.text = this._questionText.getValue().toString();
      ret.options = [];

      var optionsGrid = this._optionsGrid;
      var optLen = this._optionsLen;

      for (var i=0; i<optLen; i++)
      {
        var cellWidget = optionsGrid.getLayout().getCellWidget(i, 0);
        var id = Number(cellWidget.getUserData("id"));
        var text = cellWidget.getValue().toString();
        var checked = optionsGrid.getLayout().getCellWidget(i, 1).isChecked() ? true : false;

        ret.options.push(
        {
          id      : id,
          text    : text,
          checked : checked
        });
      }

      return ret;
    },


    /**
     * TODOC
     *
     * @param e {Event} TODOC
     * @return {void} 
     */
    _removeOption : function(e)
    {
      var index = this._optionsGrid.indexOf(e.getTarget()) - 2;

      for (var i=0; i<3; i++) {
        this._optionsGrid.removeAt(index);
      }

      this._optionsLen--;
    },


    /**
     * TODOC
     *
     * @param optionsGrid {var} TODOC
     * @param index {var} TODOC
     * @param option {var} TODOC
     * @return {void} 
     */
    _addOption : function(optionsGrid, index, option)
    {
      var optionText = new qx.ui.form.TextField(option.text.toString());
      optionText.setUserData("id", option.id);
      optionText.setWidth(150);

      var checkBox = new qx.ui.form.CheckBox();
      checkBox.setValue(option.checked ? true : false);

      var removeButton = new qx.ui.form.Button("Quitar Opcion");
      removeButton.setAllowGrowX(false);
      removeButton.setAllowGrowY(false);
      removeButton.addListener("execute", this._removeOption, this);

      optionsGrid.add(optionText,
      {
        row    : index,
        column : 0
      });

      optionsGrid.add(checkBox,
      {
        row    : index,
        column : 1
      });

      optionsGrid.add(removeButton,
      {
        row    : index,
        column : 2
      });
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _doAddOption : function()
    {
      this._addOption(this._optionsGrid, this._optionsLen,
      {
        id      : -1,
        text    : "",
        checked : false
      });

      this._optionsLen++;
    }
  }
});
