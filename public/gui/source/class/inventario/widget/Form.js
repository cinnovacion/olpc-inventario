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


/**********************************************************************************
  #ignore(hex_sha1)
************************************************************************************/

qx.Class.define("inventario.widget.Form",
{
  extend : qx.core.Object,

  construct : function() {},

  statics :
  {
    /**
     * loadComboBox(): cargar un combo box y setea el que esta seleccionado
     * @param cb {qx.ui.form.SelectBox}
     * @param vdata {Array}  vector de hashes {text,value,selected,attribs} donde attribs es hash de atributos
     * @param sel {Boolean} marcar alguno como seleccionado (si no se seleccino otro)
     * @return void
     */
    loadComboBox : function(cb, vdata, sel) {
      var len = (vdata) ? vdata.length : 0;
      var hasSelected = false;

      /* clear the comboBox before starting */
      inventario.widget.Form.clearComboBox(cb);  

      for (var i=0; i<len; i++) {
        var t = vdata[i].text;
        var v = vdata[i].value.toString();
        var attribs = (vdata[i].attribs ? vdata[i].attribs : {});
        var s = vdata[i].selected ? vdata[i].selected : false;
        var li = new qx.ui.form.ListItem(t, null, v);

        cb.add(li);

        if (s) {
          hasSelected = true;
          cb.setSelection([li]);
        }

        /* save the attribs of the option */
        for (var j in attribs) {
          li.setUserData(j, attribs[j]);
        }
      }

      if (!hasSelected && sel && len) {
         var tmp = cb.getSelectables();
         if (tmp.length > 0) {
            cb.setSelection([tmp[0]]);
         }
      }
    },

    comboBoxToHash : function(cb)
    {
      return {
        text  : cb.getField().getValue(),
        value : inventario.widget.Form.getInputValue(cb)
      };
    },

    setComboBox : function(cb, value) {
      var items = value.getSelectables();
      for (var i in items) {
          if (i.getModel().toString() == value.toString()) {
                cb.setSelection([i]);
                return true;
          }
      }
      return false;
    },

    setComboBoxByUserData : function(cb, value, userData)
    {
      var lista = cb.getList().getChildren();
      var len = (lista ? lista.length : 0);

      for (var i=0; i<len; i++) {
        var s = lista[i].getUserData(userData);

        if (s == value) {
          cb.setSelected(lista[i]);
          break;
        }
      }
    },

    clearComboBox : function(cb)
    {
      cb.removeAll();
      cb.setSelection([]);
    },

    /**
     * setWithNumberFormat(): carga en un textfield un numero
     *
     * @param input {var} qx.ui.form.TextField
     * @param num {Number} numeric
     * @return {void} void
     */
    setWithNumberFormat : function(input, num)
    {
      var cant_decimales = 0;

      try {
        cant_decimales = input.getUserData("cant_decimales");

        if (parseInt(cant_decimales)) {
          cant_decimales = parseInt(cant_decimales);
        } else {
          cant_decimales = 0;
        }
      } catch(e) {
        cant_decimales = 0;
      }

      var val = inventario.widget.Form.formatNumberToString(num, cant_decimales);
      input.setValue(val);
    },


    /**
     * unFormatNumber(): invierte lo que hace setWithNumberFormat
     *
     * @param num {Number} string con el numero
     * @return {var} float
     *   
     *     Javascript no acepta los separadores de miles :S
     */
    unFormatNumber : function(num)
    {
      var str = num.toString();
      var y = str.replace(/\./g, "");
      y = y.replace(/\,/g, ".");

      return parseFloat(y);
    },

    /**
     * formatNumberToString(): devuelve un string formateado de numero
     *
     * @param num {Number} number
     * @param cant_decimales {Number} cantidad de decimales
     * @return {var} string
     */
    formatNumberToString : function(num, cant_decimales)
    {
      var f = new qx.util.format.NumberFormat("es");
      f.set({ maximumFractionDigits : cant_decimales });
      return f.format(num).toString();
    },

    /**
     * parseStringToNumber(): devuelve un string formateado de numero
     *
     * @param num {Number} string
     * @return {var} double
     */
    parseStringToNumber : function(num)
    {
      var f = new qx.util.format.NumberFormat("es");

      f.set(
      {
        maximumFractionDigits : 0,
        prefix                : "",
        postfix               : ""
      });

      return f.parse(num);
    },

    /* FIXME: this should be simplified by making widget comply with an interface (i.e.: getValue()) */
    getInputValue : function(pInput, rich_output) {
      var v = "";

      if (pInput instanceof qx.ui.form.PasswordField) {
        var string = pInput.getValue().toString();

        if (string != "") {
          v = hex_sha1(string);
        } else {
          v = string;
        }
      }
      else if (pInput instanceof qx.ui.form.TextField || pInput instanceof qx.ui.form.TextArea || pInput instanceof qx.ui.form.Spinner)
      {
        v = pInput.getValue();

        if (rich_output)
        {
          h = {};
          h.value = v;
          h.text = v;
          v = h;
        }
      }
      else if (pInput instanceof qx.ui.form.DateField)
      {
        var dateObj = pInput.getValue();

        if (dateObj)
        {
          var monthStr = (dateObj.getMonth() + 1).toString();
          v = dateObj.getDate().toString() + "-" + monthStr + "-" + dateObj.getFullYear().toString();
        }
        else
        {
          v = "";
        }

        if (rich_output)
        {
          h = {};
          h.value = v;
          h.text = v;
          v = h;
        }
      }
      else if (pInput instanceof qx.ui.form.SelectBox)
      {
        if (pInput.getUserData("text_value") == true) {
            var zSel = pInput.getSelection();
            v = zSel.length > 0 ? zSel[0].getLabel() : "";
        }
        else
        {
            var zSel = pInput.getSelection();
            v = zSel.length > 0 ? zSel[0].getModel() : -1;

            if (rich_output)
            {
                var h = { text : "", value : -1};
                if (zSel.length > 0) {
                  h.text  = zSel[0].getLabel();  
                  h.value = v;
                } 
                v = h;
            }
        }
      }
      else if (pInput instanceof qx.ui.form.CheckBox)
      {
        v = pInput.getValue();
      }
      else if (pInput instanceof inventario.widget.Table2)
      {
        v = pInput.getHashedData();
      }
      else if (pInput instanceof inventario.widget.DateRange)
      {
        v = pInput.getValue();
      }
      else if (pInput instanceof inventario.widget.CheckboxSelector)
      {
        v = pInput.getSelectedParts();
      }
      else if (pInput instanceof inventario.widget.ComboboxSelector)
      {
        v = pInput.getSelectedValue();
      }
      else if (pInput instanceof inventario.widget.ColumnValueSelector)
      {
        v = pInput.getValues();
      }
      else if (pInput instanceof inventario.widget.ListSelector)
      {
        v = pInput.getSelectedValue();
      }
      else if (pInput instanceof inventario.widget.DynTable)
      {
        v = pInput.getTableData();  // ?
      }
      else if (pInput instanceof inventario.widget.Select)
      {
        var s = pInput.getComboBox().getChildrenContainer().getSelectedItem();
        v = (s ? s.getValue() : -1);

        if (rich_output)
        {
          var h = {};
          h.text = pInput.getComboBox().getValue();
          h.value = v;
          v = h;
        }
      } else if (pInput instanceof inventario.widget.Permissions) {
        v = pInput.getTreeValues();
      } else if (pInput instanceof inventario.widget.MapLocator) {
        v = pInput.getValues();
      } else if (pInput instanceof inventario.widget.DynamicBarcodeScanForm) {
        v = pInput.getValues();
      } else if (pInput instanceof inventario.widget.DynamicDeliveryForm) {
        v = pInput.getValues();
      } else if (pInput instanceof inventario.widget.CoordsTextField) {
        v = pInput.getInputValue();
      } else if (pInput instanceof inventario.widget.ComboBoxFiltered) {
        v = pInput.getSelectedValue();
      } else if (pInput instanceof inventario.widget.HierarchyOnDemand) {
        v = pInput.getValue();

        if (rich_output)
        {
          var h = {};
          h.text = pInput.getItemFullLabel();
          h.value = v;
          v = h;
        }
      } else if (pInput instanceof inventario.widget.MultipleHierarchySelection) {
        v = pInput.getValues();
      } else {
        alert(qx.locale.Manager.tr("I don't know the data type ") + typeof (pInput));
      }

      return v;
    },

    /**
     * resetInputs() :  set inputs to inital state
     */
    resetInputs : function(arrayInputs)
    {
      var len = arrayInputs.length;

      for (var i=0; i<len; i++) {
        var pInput = arrayInputs[i];

        if (pInput instanceof qx.ui.form.TextField) {
          pInput.setValue("");
        } else if (pInput instanceof qx.ui.form.SelectBox) {

          try {
            var child = pInput.getList().getFirstChild();
            pInput.setSelected(child);
          } catch(e) {
            pInput.setSelected(null);
          }

        } else if (pInput instanceof qx.ui.form.Spinner) {
          pInput.setValue(0);
        } else if (pInput instanceof qx.ui.form.CheckBox) {
          pInput.setValue(false);
        } else if (pInput instanceof qx.ui.form.TextArea) {
          pInput.setValue("");
        }
      }
    },

    /**
     * createLayout
     *
     * @param vdata {var} hash{clase,width,height} de cada columna
     */
    createLayout : function(vdata)
    {
      var lay = new vdata["clase"];

      lay.setLeft(0);
      lay.setTop(0);
      lay.setDimension(vdata["width"], vdata["height"]);
      lay.setSpacing(2);
      lay.setPadding(0);

      return lay;
    }

  }
});
