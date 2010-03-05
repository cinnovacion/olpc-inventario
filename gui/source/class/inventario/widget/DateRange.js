
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
// DateRange.js
// fecha: 2007-06-1
// autor: Kaoru Uchiyamada
//
// TODO: be able to set (default) begin and end dates
qx.Class.define("inventario.widget.DateRange",
{
  extend : qx.ui.container.Composite,




  /*
      *****************************************************************************
         CONSTRUCTOR
      *****************************************************************************
      */

  construct : function(options)
  {
    try
    {
      qx.ui.container.Composite.call(this, new qx.ui.layout.HBox(20));

      var desde = new qx.ui.form.DateField();
      var hasta = new qx.ui.form.DateField();

      this.add(new qx.ui.basic.Label(qx.locale.Manager.tr(" From: ")));
      this.add(desde);
      this.add(new qx.ui.basic.Label(qx.locale.Manager.tr(" Until: ")));
      this.add(hasta);

      this.setHasta(hasta);
      this.setDesde(desde);
    }
    catch(e)
    {
      alert(e.toString());
    }
  },




  /*
      *****************************************************************************
         PROPERTIES
      *****************************************************************************
      */

  properties :
  {
    hasta : { check : "Object" },
    desde : { check : "Object" }
  },




  /*
      *****************************************************************************
         MEMBERS
      *****************************************************************************
      */

  members :
  {
    /**
     * TODOC
     *
     * @return {Map} TODOC
     */
    getValue : function()
    {
      var date_since = inventario.widget.Form.getInputValue(this.getDesde());
      var date_to = inventario.widget.Form.getInputValue(this.getHasta());

      return {
        date_since : date_since,
        date_to    : date_to
      };
    },

    /*
                @params desde {string}
                @params hasta {string}
            */

    /**
     * TODOC
     *
     * @param desde {var} TODOC
     * @param hasta {var} TODOC
     * @return {void} 
     */
    setValue : function(desde, hasta)
    {
      var aux = this._dateElements(desde);
      this.getDesde().setValue(new Date(aux.year, aux.month, aux.date));

      var aux2 = this._dateElements(hasta);
      this.getHasta().setValue(new Date(aux2.year, aux2.month, aux2.date));
    },


    /**
     * TODOC
     *
     * @param date {var} TODOC
     * @return {var} TODOC
     */
    _dateElements : function(date)
    {
      // alert(date);
      // date = dd-mm-yyyy
      var ret = {};
      var tmp = date.split("-");
      ret.year = tmp[2];
      ret.month = Number(tmp[1]) - 1;
      ret.date = tmp[0];

      return ret;
    }
  }
});
