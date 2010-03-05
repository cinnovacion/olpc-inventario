
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
// CoordsTextField.js
// Small widget for converting and storing global world coordinates.
// Author: Martin Abente (tincho_02@hotmail.com | mabente@paraguayeduca.org)
// Paraguay Educa 2009
qx.Class.define("inventario.widget.CoordsTextField",
{
  extend : qx.ui.container.Composite,

  /*
       * CONSTRUCTOR
       */

  construct : function(decimals)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(20));

      // We create all the layouts.
      var gl = new qx.ui.container.Composite(new qx.ui.layout.Grid());
      this._grid_layout = gl;
      this.add(gl);

      // Labels and TextFields
      gl.add(new qx.ui.basic.Label(qx.locale.Manager.tr("Decimals")),
      {
        row    : 0,
        column : 0
      });

      var decimalsText = new qx.ui.form.TextField();
      decimalsText.setValue(decimals.toString());

      gl.add(decimalsText,
      {
        row    : 0,
        column : 1
      });

      gl.add(new qx.ui.basic.Label(qx.locale.Manager.tr("Degrees")),
      {
        row    : 1,
        column : 0
      });

      var degreesText = new qx.ui.form.TextField();

      gl.add(degreesText,
      {
        row    : 1,
        column : 1
      });

      gl.add(new qx.ui.basic.Label(qx.locale.Manager.tr("Minutes")),
      {
        row    : 1,
        column : 2
      });

      var minutesText = new qx.ui.form.TextField();

      gl.add(minutesText,
      {
        row    : 1,
        column : 3
      });

      gl.add(new qx.ui.basic.Label(qx.locale.Manager.tr("Seconds")),
      {
        row    : 1,
        column : 4
      });

      var secondsText = new qx.ui.form.TextField();

      gl.add(secondsText,
      {
        row    : 1,
        column : 5
      });

      this.setDecimalsText(decimalsText);
      this.setDegreesText(degreesText);
      this.setMinutesText(minutesText);
      this.setSecondsText(secondsText);

      degreesText.addListener("input", this._degreesToDecimal, this);
      minutesText.addListener("input", this._degreesToDecimal, this);
      secondsText.addListener("input", this._degreesToDecimal, this);
    }
    catch(e)
    {
      alert(e.toString());
    }
  },

  /*
       * PROPERTIES
       */

  properties :
  {
    decimalsText :
    {
      check    : "Object",
      nullable : true,
      init     : null
    },

    degreesText :
    {
      check    : "Object",
      nullable : true,
      init     : null
    },

    minutesText :
    {
      check    : "Object",
      nullable : true,
      init     : null
    },

    secondsText :
    {
      check    : "Object",
      nullable : true,
      init     : null
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
    getInputValue : function() {
      return this.getDecimalsText().getValue();
    },


    /**
     * TODOC
     *
     * @return {void} 
     */
    _degreesToDecimal : function()
    {
      var degrees = Number(this.getDegreesText().getValue());
      var minutes = Number(this.getMinutesText().getValue());
      var seconds = Number(this.getSecondsText().getValue());

      var decimals = (degrees + (minutes / 60) + (seconds / 3600));
      this.getDecimalsText().setValue(decimals.toString());
    }
  }
});
